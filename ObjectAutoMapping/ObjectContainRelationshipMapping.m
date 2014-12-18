//
//  ObjectContainshipMapping.m
//  ObjectAutoMapping
//
//  Created by Dong on 12/12/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectContainRelationshipMapping.h"

@implementation ObjectContainRelationshipMapping

+ (ObjectContainRelationshipMapping *)mappingFromKeyPath:(NSString *)sourceKeyPath
                                       toKeyPath:(NSString *)destinationKeyPath
                                     withContainMappingClass:(Class)containDynamicyMappingClass {
    ObjectContainRelationshipMapping *cRelationshipMapping = (ObjectContainRelationshipMapping *)[self mappingFromKeyPath:sourceKeyPath toKeyPath:destinationKeyPath];
    cRelationshipMapping.containMappingClass = containDynamicyMappingClass;
    return cRelationshipMapping;
}

- (id)copyWithZone:(NSZone *)zone {
    ObjectContainRelationshipMapping *copy = [self copyWithZone:zone];
    copy.containMappingClass = self.containMappingClass;
    return copy;
}

@end
