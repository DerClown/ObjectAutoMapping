//
//  ObjectAutoMapping.h
//  ObjectAutoMapping
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectAttributeTransformator.h"


#if TARGET_IPHONE_SIMULATOR
#define OAMLog(s, ... ) NSLog( @"[%@:%d] %@", [[NSString stringWithUTF8String:__FILE__] \
lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define OAMog(s, ... )
#endif

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
