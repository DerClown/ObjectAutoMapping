//
//  JsonShipModel.m
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/15/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "JsonShipModel.h"

@implementation JsonShipModel

- (ObjectAttributeTransformator *)transformator {
    ObjectAttributeTransformator *transformator = [ObjectAttributeTransformator attributeTransformator];
    [transformator mapSourceKeyPath:@"thumb_Image" toAttribute:@"thumbImg"];
    [transformator mapSourceKeyPath:@"personal_info" toAttribute:@"shipModel"];
    
    return transformator;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\r thumbImg %@, products %@ shipModel %@ \r", self.thumbImg, self.products, self.shipModel];
}


@end
