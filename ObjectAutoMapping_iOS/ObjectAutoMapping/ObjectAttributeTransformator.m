//
//  ObjectMapperTransformator.m
//  ObjectAutoMapping
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAttributeTransformator.h"

@implementation ObjectAttributeTransformator

- (void)dealloc {
    [_transformators removeAllObjects];
    _transformators = nil;
}

+ (id)attributeTransformator {
    ObjectAttributeTransformator *aTransformator = [[ObjectAttributeTransformator alloc] init];
    return aTransformator;
}

- (NSArray *)attributeMappings {
    NSMutableArray *mappings = [NSMutableArray array];
    for (ObjectAttributeMapping *attributeMapping in _transformators) {
        if ([attributeMapping isMemberOfClass:[ObjectAttributeMapping class]]) {
            [mappings addObject:attributeMapping];
        }
    }
    return mappings;
}

- (NSArray *)containshipMappings {
    NSMutableArray *mappings = [NSMutableArray array];
    for (ObjectAttributeMapping *attributeMapping in _transformators) {
        if ([attributeMapping isMemberOfClass:[ObjectContainRelationshipMapping class]]) {
            [mappings addObject:attributeMapping];
        }
    }
    
    return mappings;
}

- (void)addTransformatorAttributes:(ObjectAttributeMapping *)attributeMapping, ... {
    va_list args;
    va_start(args, attributeMapping);
    NSMutableSet *attributeTransformators = [NSMutableSet set];

    for (ObjectAttributeMapping *candidateAttribute = attributeMapping; candidateAttribute != nil; candidateAttribute = va_arg(args, ObjectAttributeMapping *)) {
        [attributeTransformators addObject:candidateAttribute];
    }
    
    va_end(args);
    
    [self addTransformatorAttributesCollection:attributeTransformators];
}

#pragma mark - Retrieving Methods

- (void)mapSourceKeyPath:(NSString *)sourceKeyPath toAttribute:(NSString *)destinationAttribute {
    ObjectAttributeMapping *mapping = [ObjectAttributeMapping mappingFromKeyPath:sourceKeyPath toKeyPath:destinationAttribute];
    [self addTransformatAttributes:mapping];
}

- (void)mapSourceKeyPath:(NSString *)sourceKeyPath toContainRelationship:(NSString *)destContainRelationship withContainMappingClass:(Class)containDynamicyMapping {
    ObjectContainRelationshipMapping *shipMapping = [ObjectContainRelationshipMapping mappingFromKeyPath:sourceKeyPath toKeyPath:destContainRelationship withContainMappingClass:containDynamicyMapping];
    [self addTransformatAttributes:shipMapping];
}

- (ObjectAttributeMapping *)mappingForAttribute:(NSString *)attributeKey {
    for (ObjectAttributeMapping *mapping in [self attributeMappings]) {
        if ([mapping.sourceKeyPath isEqualToString:attributeKey]) {
            return mapping;
        }
    }
    
    return nil;
}

- (ObjectContainRelationshipMapping *)mappingForContainship:(NSString *)sourceKeyPath {
    for (ObjectContainRelationshipMapping *shipMaping in [self containshipMappings]) {
        if ([shipMaping.sourceKeyPath isEqualToString:sourceKeyPath]) {
            return shipMaping;
        }
    }
    
    return nil;
}

- (BOOL)isExistAttributeForDestinationKeyPath:(NSString *)destinationKeyPath {
    for (ObjectAttributeMapping *mapping in _transformators) {
        if ([mapping.destinationKeyPath isEqualToString:destinationKeyPath]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Private Methods

- (void)addTransformatorAttributesCollection:(id<NSFastEnumeration>)transformatorAttributes {
    for (ObjectAttributeMapping *candidateAttribute in transformatorAttributes) {
        [self addTransformatAttributes:candidateAttribute];
    }
}

- (void)addTransformatAttributes:(ObjectAttributeMapping *)attributeMapping {
    if (!_transformators) {
        _transformators = [NSMutableArray arrayWithCapacity:1];
    }
    
    if (![_transformators containsObject:attributeMapping]) {
        [_transformators addObject:attributeMapping];
    }
}

@end
