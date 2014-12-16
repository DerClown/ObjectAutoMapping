//
//  JosnModel.m
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "JosnModel.h"
#import "ContainshipModel.h"

@implementation JosnModel

- (ObjectAttributeTransformator *)transformator {
    ObjectAttributeTransformator *transformator = [ObjectAttributeTransformator attributeTransformator];
    [transformator mapSourceKeyPath:@"username" toAttribute:@"name"];
    [transformator mapSourceKeyPath:@"avatar" toContainRelationship:@"new" withContainMappingClass:[ContainshipModel class]];
    
    return transformator;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name %@, password %@ avatar %@", self.name, self.password, self.avatar];
}

@end
