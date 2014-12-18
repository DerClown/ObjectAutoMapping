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

static const char * kClassPropertiesKey;

#define FilterNullString(string) [string isKindOfClass:[NSNull class]] ? @"" : string
#define FilterNullNumber(num) [num isKindOfClass:[NSNull class]] ? @"0" : num

#define EqualString(string, aString) [string isEqualToString:aString]

@interface ObjectAutoMapping()

@property (nonatomic, strong) ObjectAttributeTransformator *transformator;
//@property (nonatomic) id theClass;
@property (nonatomic, strong) NSMutableDictionary *ralationshipMappingContext;
@property (nonatomic, strong) NSMutableDictionary *properiesContext;
@property (nonatomic, copy) NSString *attributeClassName;

@end

@implementation ObjectAutoMapping

- (void)dealloc {
    [_properiesContext removeAllObjects];
    _properiesContext = nil;
    _attributeClassName = nil;
    _transformator = nil;
    [_ralationshipMappingContext removeAllObjects];
    _ralationshipMappingContext = nil;
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
    if (_properiesContext.count == 0) {
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
    //NSDictionary *properties = objc_getAssociatedObject(_theClass, &kClassPropertiesKey);
    if (_properiesContext && _properiesContext.count > 0) {
        for (NSString *sourceKeyPath in [sourceObject allKeys]) {
            ObjectAttributeMapping *attMapping = [_transformator mappingForAttribute:sourceKeyPath];
            
            if (!attMapping) {
                ObjectContainRelationshipMapping *cRelationshiMapping = [_transformator mappingForContainship:sourceKeyPath];
                if (!cRelationshiMapping || ![sourceObject[sourceKeyPath] isKindOfClass:[NSArray class]]) {
                    continue;
                }
                
                if (![_properiesContext.allKeys containsObject:cRelationshiMapping.destinationKeyPath]) {
                    continue;
                }
                
                [self containRelationshipMapping:cRelationshiMapping withObject:sourceObject[sourceKeyPath]];
            } else {
                if (![_properiesContext.allKeys containsObject:attMapping.destinationKeyPath]) continue;
                
                [self attributeMapping:attMapping withObject:sourceObject[sourceKeyPath]];
            }
        }
    }
    
    //objc_setAssociatedObject(_theClass, &kClassPropertiesKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

- (void)attributeMapping:(ObjectAttributeMapping *)attMapping withObject:(id)object {
    if ([_properiesContext[attMapping.destinationKeyPath] integerValue] == MappingPropertyClass) {
        Class relationshipClass = NSClassFromString(_ralationshipMappingContext[attMapping.destinationKeyPath]);
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
        id value = [self transformTargetValue:object withPorpertyType:[_properiesContext[attMapping.destinationKeyPath] intValue]];
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
    if (!_properiesContext || _properiesContext.count == 0) {
        [self setupProperties];
    }
}

- (void)setupProperties {
    _properiesContext = [NSMutableDictionary dictionary];
    _ralationshipMappingContext = [NSMutableDictionary dictionary];
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
        
        [_properiesContext setObject:@(propertyType) forKey:propertyAttribute];
        if (_attributeClassName) [_ralationshipMappingContext setObject:_attributeClassName forKey:propertyAttribute];
        _attributeClassName = nil;
    }
    
    free(properties);
    
    //objc_setAssociatedObject(_theClass, &kClassPropertiesKey, classProperties, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary*)_classProperties {
    //fetch the associated object
    NSDictionary* classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    if (classProperties) return classProperties;
    
    //if here, the class needs to inspect itself
    [self _setup];
    
    //return the properties
    classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    return classProperties;
}

- (void)inspectTransformators {
    _transformator = [self transformator] ? [self transformator] : [ObjectAttributeTransformator attributeTransformator];
    //NSDictionary *properties = objc_getAssociatedObject(_theClass, &kClassPropertiesKey);
    for (NSString *destinationKey in [_properiesContext allKeys]) {
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
        _attributeClassName = resString;
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
        if (![sourceObject.allKeys containsObject:attMapping.sourceKeyPath]) {
            [misMatchs addObject:attMapping.destinationKeyPath];
        } else {
            if (![_properiesContext.allKeys containsObject:attMapping.destinationKeyPath]) {
                [misMatchs addObject:attMapping.destinationKeyPath];
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
