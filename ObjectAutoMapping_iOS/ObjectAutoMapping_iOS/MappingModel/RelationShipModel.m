//
//  RelationShipModel.m
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/15/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "RelationShipModel.h"

@implementation RelationShipModel

- (ObjectAttributeTransformator *)transformator {
    ObjectAttributeTransformator *transformator = [ObjectAttributeTransformator attributeTransformator];
    [transformator mapSourceKeyPath:@"id" toAttribute:@"uniqueId"];
    
    return transformator;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"lastmame %@, firstmame %@ id %ld", self.firstname, self.lastname, (long)self.uniqueId];
}

@end
