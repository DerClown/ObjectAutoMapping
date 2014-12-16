//
//  ObjectContainshipMapping.h
//  ObjectAutoMapping
//
//  Created by Dong on 12/12/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAttributeMapping.h"

@class ObjectAutoMapping;

@interface ObjectContainRelationshipMapping : ObjectAttributeMapping

@property (nonatomic, assign) Class containMappingClass;

+ (ObjectContainRelationshipMapping *)mappingFromKeyPath:(NSString *)sourceKeyPath
                                        toKeyPath:(NSString *)destinationKeyPath
                                      withContainMappingClass:(Class)containMappingClass;

@end
