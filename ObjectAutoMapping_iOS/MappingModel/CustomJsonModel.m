//
//  CustomJsonModel.m
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/15/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "CustomJsonModel.h"

@implementation CustomJsonModel

- (NSString *)description {
    return [NSString stringWithFormat:@"\r name %@, country %@ otherInfos %@ \r", self.name, self.country, self.otherInfos];
}

@end
