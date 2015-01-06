//
//  ObjectAutoMapping.m
//  ObjectAutoMapping
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAutoMapping.h"
#import <objc/runtime.h>
#import "ObjectMappingError.h"
#import "ObjectAttributeMapping.h"
#import "ObjectAttributeTransformator.h"

#define FilterNullString(string) [string isKindOfClass:[NSNull class]] ? @"" : string
#define FilterNullNumber(num) [num isKindOfClass:[NSNull class]] ? @"0" : num

#define EqualString(string, aString) [string isEqualToString:aString]

@interface ObjectAutoMapping()

@property (nonatomic, strong) ObjectAttributeTransformator *transformator;
@property (nonatomic, strong) NSMutableDictionary *ralationshipMappingContexts;
@property (nonatomic, strong) NSMutableDictionary *propertyValueContexts;
@property (nonatomic, copy) NSString *mappingClassName;

@end

@implementation ObjectAutoMapping

- (void)dealloc {
    [_propertyValueContexts removeAllObjects];
    _propertyValueContexts = nil;
    _mappingClassName = nil;
    _transformator = nil;
    [_ralationshipMappingContexts removeAllObjects];
    _ralationshipMappingContexts = nil;
    OAMLog(@"%s", __FUNCTION__);
}

#pragma mark - initalization

- (id)initWithSoureceObject:(id)sourceObject error:(NSError **)error {
    if (self = [self init]) {
        [self mappingSourceObjectToAttributes:sourceObject error:error];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}

#pragma mark - Mapping methods

- (void)mappingSourceObjectToAttributes:(id)sourceObject error:(NSError **)error {
    //check for nil input
    if (!sourceObject) {
        if (error)
            *error = [ObjectMappingError errorInvalidDataWithMessage:@"Initializing model with nil input object."];
        return;
    }
    
    if (![sourceObject isKindOfClass:[NSDictionary class]]) {
        if (error)
            *error = [ObjectMappingError errorInvalidDataWithMessage:@"Attempt to initialize JSONModel object using initWithDictionary:error: but the dictionary parameter was not an 'NSDictionary'."];
        return;
    }
    
    //check for class properties
    if (_propertyValueContexts.count == 0) {
        if (error)
            *error = [ObjectMappingError errorWithUnMappableContent];
        return;
    }
    
    NSSet *misMatchs = [self getObjectMappingMismatchWithSourceObject:sourceObject];
    if (misMatchs.count > 0) {
        if (error)
            *error = [ObjectMappingError errorWithObjectMappingMismatch:misMatchs];
    }
    
    [self mappingAttributesWithSourceObject:(NSDictionary *)sourceObject];
}

- (void)mappingAttributesWithSourceObject:(NSDictionary *)sourceObject {
    if (_propertyValueContexts && _propertyValueContexts.count > 0) {
        for (NSString *attribute in _propertyValueContexts.allKeys) {
            ObjectAttributeMapping *attMapping = [_transformator mappingForAttribute:attribute];
            
            if (!attMapping) {
                ObjectContainRelationshipMapping *cRelationshiMapping = [_transformator mappingForContainshipAttribute:attribute];
                if (!cRelationshiMapping || ![sourceObject[cRelationshiMapping.sourceKeyPath] isKindOfClass:[NSArray class]]) {
                    continue;
                }
                
                if (![sourceObject.allKeys containsObject:cRelationshiMapping.sourceKeyPath]) {
                    continue;
                }
                
                [self containRelationshipMapping:cRelationshiMapping withObject:sourceObject[cRelationshiMapping.sourceKeyPath]];
            } else {
                id attSourceObject = sourceObject[attMapping.sourceKeyPath];
                
                NSString *sourceKeyPath = attMapping.sourceKeyPath;
                if ([sourceKeyPath rangeOfString:@"."].location != NSNotFound) {
                    NSArray *sourceKeys = [attMapping.sourceKeyPath componentsSeparatedByString:@"."];
                    sourceKeyPath = sourceKeys.firstObject;
                    
                    if (![[sourceObject objectForKey:sourceKeys.firstObject] isKindOfClass:[NSDictionary class]] || sourceKeys.count < 2) {
                        continue;
                    }
                    
                    NSDictionary *destDic = [sourceObject objectForKey:sourceKeys.firstObject];
                    for (int i = 0; i < sourceKeys.count - 2; i ++) {
                        destDic = [destDic objectForKey:sourceKeys[i+1]];
                    }
                    
                    attSourceObject = [destDic objectForKey:sourceKeys.lastObject];
                }
                
                if (![sourceObject.allKeys containsObject:sourceKeyPath]) continue;
                
                [self attributeMapping:attMapping withObject:attSourceObject];
            }
        }
    }
}

- (void)attributeMapping:(ObjectAttributeMapping *)attMapping withObject:(id)object {
    if ([_propertyValueContexts[attMapping.destinationKeyPath] integerValue] == MappingPropertyClass) {
        Class relationshipClass = NSClassFromString(_ralationshipMappingContexts[attMapping.destinationKeyPath]);
        id relationshipMapping = [relationshipClass new];
        
        NSError *error;
        if (![relationshipMapping isKindOfClass:[ObjectAutoMapping class]]) {
            error = [ObjectMappingError errorMappingModelIsInvalid];
            OAMLog(@"'%@' Mapping %@", NSStringFromClass(relationshipClass), error);
            return;
        }
        
        [relationshipMapping mappingSourceObjectToAttributes:object error:&error];
        if (error) OAMLog(@"'%@' error %@", NSStringFromClass(relationshipClass), error);
        
        [self setValue:relationshipMapping forKey:attMapping.destinationKeyPath];
    } else {
        id value = [self transformTargetValue:object withPorpertyType:[_propertyValueContexts[attMapping.destinationKeyPath] intValue]];
        [self setValue:value forKey:attMapping.destinationKeyPath];
    }
}

- (void)containRelationshipMapping:(ObjectContainRelationshipMapping *)cRelationshipMapping withObject:(id)object {
    id containMappingClass = [cRelationshipMapping.containMappingClass new];
    NSMutableArray *contains = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *containSourceObject in (NSArray *)object) {
        NSError *error;
        if (![containMappingClass isKindOfClass:[ObjectAutoMapping class]]) {
            error = [ObjectMappingError errorMappingModelIsInvalid];
            OAMLog(@"'%@' %@", NSStringFromClass([containMappingClass class]), error);
            continue;
        }
        
        [containMappingClass mappingSourceObjectToAttributes:containSourceObject error:&error];
        if (error) OAMLog(@"'%@' %@", NSStringFromClass([containMappingClass class]), error);
        
        [contains addObject:containMappingClass];
    }
    [self setValue:contains forKey:cRelationshipMapping.destinationKeyPath];
}

#pragma mark - overwrite method

- (ObjectAttributeTransformator *)transformator {
    return nil;
}

#pragma mark - property && transformator inspection methods

- (void)_setup {
    [self inspectProperties];
    [self inspectTransformators];
}

- (void)inspectProperties {
    if (!_propertyValueContexts || _propertyValueContexts.count == 0) {
        [self setupProperties];
    }
}

- (void)setupProperties {
    _propertyValueContexts = [NSMutableDictionary dictionary];
    _ralationshipMappingContexts = [NSMutableDictionary dictionary];
    unsigned int propertyCount;
    NSString *className = NSStringFromClass([self class]);
    const char *cClassName = [className UTF8String];
    Class _theClass = objc_getClass(cClassName);
    objc_property_t *properties = class_copyPropertyList(_theClass, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString *propertyAttribute = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        //get property attributes
        const char *attribute = property_getAttributes(property);
        NSString *attriburtes = [NSString stringWithCString:attribute encoding:NSUTF8StringEncoding];
        
        NSArray *attributeItems = [attriburtes componentsSeparatedByString:@","];
        MappingPropertyTypes propertyType = [self mappingPorpertyTypeWithAttributeString:attributeItems[0]];
        
        [_propertyValueContexts setObject:@(propertyType) forKey:propertyAttribute];
        if (_mappingClassName) [_ralationshipMappingContexts setObject:_mappingClassName forKey:propertyAttribute];
        _mappingClassName = nil;
    }
    
    free(properties);
}

- (void)inspectTransformators {
    _transformator = [self transformator] ? [self transformator] : [ObjectAttributeTransformator attributeTransformator];
    
    for (NSString *destinationKey in [_propertyValueContexts allKeys]) {
        ObjectAttributeMapping *attribute = [ObjectAttributeMapping mappingFromKeyPath:destinationKey toKeyPath:destinationKey];
        if ([_transformator isExistAttributeForDestinationKeyPath:destinationKey]) continue;
        [_transformator addTransformatorAttributes:attribute, nil];
    }
}

#pragma mark - get property type methods

- (MappingPropertyTypes)mappingPorpertyTypeWithAttributeString:(NSString *)attString {
    MappingPropertyTypes propertyType = -1;
    
    NSString *scanString = @"T";
    if ([attString hasPrefix:@"T@"]) {
        scanString = @"T@";
    }
    
    attString = [attString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSScanner *aScanner = [NSScanner scannerWithString:attString];
    NSString *resString;
    [aScanner scanString:scanString intoString:NULL];
    [aScanner scanUpToCharactersFromSet:[NSCharacterSet decomposableCharacterSet]
                             intoString:&resString];
    
    propertyType = [self getPropertyTypeByScanResString:resString];
    
    if (propertyType == MappingPropertyClass) {
        _mappingClassName = resString;
    }
    
    return propertyType;
}

- (MappingPropertyTypes)getPropertyTypeByScanResString:(NSString *)resString {
    MappingPropertyTypes propertyType;
    if (!resString) {
        propertyType = MappingPropertyUnknow;
    } else {
        if (EqualString(resString, @"i") || EqualString(resString, @"I")) {
            propertyType = MappingPropertyInt;
        } else if (EqualString(resString, @"B") || EqualString(resString, @"c")) {
            propertyType = MappingPropertyBOOL;
        } else if (EqualString(resString, @"NSURL")) {
            propertyType = MappingPropertyURL;
        } else if (EqualString(resString, @"NSString")) {
            propertyType = MappingPropertyString;
        } else if (EqualString(resString, @"f") || EqualString(resString, @"b")) {
            propertyType = MappingPropertyFloat;
        } else if (EqualString(resString, @"q") || EqualString(resString, @"Q")) {
            propertyType = MappingPropertyInteger;
        } else if (EqualString(resString, @"NSArray") || EqualString(resString, @"NSMutableArray")) {
            propertyType = MappingPropertyArray;
        } else if (EqualString(resString, @"NSDictionary") || EqualString(resString, @"NSMutableDictionary")) {
            propertyType = MappingPropertyDictionary;
        } else {
            propertyType = MappingPropertyClass;
        }
    }
    return propertyType;
}

#pragma mark private methods

- (NSSet *)getObjectMappingMismatchWithSourceObject:(NSDictionary *)sourceObject {
    NSMutableSet *misMatchs = [[NSMutableSet alloc] init];
    
    for (ObjectAttributeMapping *attMapping in _transformator.transformators) {
        if ([attMapping.sourceKeyPath rangeOfString:@"."].location != NSNotFound) {
            NSArray *keys = [attMapping.sourceKeyPath componentsSeparatedByString:@"."];
            if (![sourceObject.allKeys containsObject:keys[0]] || ![sourceObject[keys[0]] isKindOfClass:[NSDictionary class]]) {
                [misMatchs addObject:attMapping.destinationKeyPath];
            } else {
                NSDictionary *dic = sourceObject[keys.firstObject];
                for (int i = 0; i < keys.count - 2; i ++) {
                    dic = [dic objectForKey:keys[i+1]];
                    if (!dic) {
                        [misMatchs addObject:attMapping.destinationKeyPath];
                        break;
                    }
                }
                
                if (dic && ![dic.allKeys containsObject:keys.lastObject]) {
                    [misMatchs addObject:attMapping.destinationKeyPath];
                }
            }
        } else {
            if (![sourceObject.allKeys containsObject:attMapping.sourceKeyPath]) {
                [misMatchs addObject:attMapping.destinationKeyPath];
            } else {
                if (![_propertyValueContexts.allKeys containsObject:attMapping.destinationKeyPath]) {
                    [misMatchs addObject:attMapping.destinationKeyPath];
                }
            }
        }
    }
    
    return misMatchs;
}

- (id)transformTargetValue:(id)targetValue withPorpertyType:(MappingPropertyTypes)propertyType {
    id value;
    if (propertyType == MappingPropertyURL) {
        targetValue = FilterNullString(targetValue);
        value = [NSURL URLWithString:targetValue];
    } else if (propertyType == MappingPropertyFloat) {
        targetValue = FilterNullNumber(targetValue);
        value = [NSNumber numberWithFloat:[targetValue floatValue]];
    } else if (propertyType == MappingPropertyInt) {
        targetValue = FilterNullNumber(targetValue);
        value = [NSNumber numberWithInt:[targetValue intValue]];
    } else if (propertyType == MappingPropertyInteger) {
        targetValue = FilterNullNumber(targetValue);
        value = [NSNumber numberWithInteger:[targetValue integerValue]];
    } else if (propertyType == MappingPropertyBOOL) {
        targetValue = FilterNullNumber(targetValue);
        value = [NSNumber numberWithBool:[targetValue boolValue]];
    } else {
        value = targetValue;
    }
    
    return value;
}

@end
