//
//  CustomJsonModel.m
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/15/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "CustomJsonModel.h"

@implementation CustomJsonModel

//- (ObjectAttributeTransformator *)transformator {
//    ObjectAttributeTransformator *transformator = [ObjectAttributeTransformator attributeTransformator];
//    [transformator mapSourceKeyPath:@"personal_infon.zone" toAttribute:@"zone"];
//    [transformator mapSourceKeyPath:@"personal_infon.zone" toAttribute:@"sign"];
//    return transformator;
//}

- (NSString *)description {
    return [NSString stringWithFormat:@"\r name %@, country %@ otherInfos %@ zone:%@ sign:%@ \r", self.name, self.country, self.otherInfos, self.zone, self.sign];
}

@end
