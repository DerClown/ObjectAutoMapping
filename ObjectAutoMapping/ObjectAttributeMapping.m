//
//  ObjectAttributeMapping.m
//  ObjectAutoMapping
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAttributeMapping.h"

@implementation ObjectAttributeMapping

- (id)initWithKeyPath:(NSString *)sourceKeyPath andDestinationKeyPath:(NSString *)destinationKeyPath {
    if (self = [super init]) {
        _sourceKeyPath = sourceKeyPath;
        _destinationKeyPath = destinationKeyPath;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ObjectAttributeMapping *copy = [[[self class] allocWithZone:zone] initWithKeyPath:self.sourceKeyPath andDestinationKeyPath:self.destinationKeyPath];
    return copy;
}

+ (ObjectAttributeMapping *)mappingFromKeyPath:(NSString *)sourceKeyPath toKeyPath:(NSString *)destinationKeyPath {
    ObjectAttributeMapping *mapping = [[self alloc] initWithKeyPath:sourceKeyPath andDestinationKeyPath:destinationKeyPath];
    return mapping;
}

@end
