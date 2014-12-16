//
//  ObjectAutoMapping.h
//  ObjectAutoMapping
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectAttributeTransformator.h"

typedef NS_ENUM(int, MappingPropertyTypes) {
    MappingPropertyUnknow = -1,
    MappingPropertyInt = 0,
    MappingPropertyFloat,
    MappingPropertyBOOL,
    MappingPropertyInteger,
    MappingPropertyDictionary,
    MappingPropertyString,
    MappingPropertyArray,
    MappingPropertyURL,
    MappingPropertyClass,
};

@interface ObjectAutoMapping : NSObject

- (id)initWithSoureceObject:(id)sourceObject error:(NSError **)error;

- (ObjectAttributeTransformator *)transformator;

@end
