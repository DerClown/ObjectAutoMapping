//
//  ObjectMapperTransformator.h
//  ObjectAutoMapping
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectAttributeMapping.h"
#import "ObjectContainRelationshipMapping.h"

@interface ObjectAttributeTransformator : NSObject {
    NSMutableArray *_transformators;
}

@property (nonatomic, readonly) NSArray *transformators;

@property (nonatomic, readonly) NSArray *attributeMappings;

@property (nonatomic, readonly) NSArray *containshipMappings;

+ (id)attributeTransformator;

- (void)mapSourceKeyPath:(NSString *)sourceKeyPath toAttribute:(NSString *)destinationAttribute;

- (void)mapSourceKeyPath:(NSString *)sourceKeyPath toContainRelationshipKeyPath:(NSString *)cRelationshipKeyPath withContainMappingClass:(Class)containDynamicyMapping;

- (void)addTransformatorAttributes:(ObjectAttributeMapping *)attributeMapping, ... NS_REQUIRES_NIL_TERMINATION;

- (ObjectAttributeMapping *)mappingForAttribute:(NSString *)attributeKey;

- (ObjectContainRelationshipMapping *)mappingForContainshipAttribute:(NSString *)attributeKey;

- (BOOL)isExistAttributeForDestinationKeyPath:(NSString *)destinationKeyPath;

@end
