//
//  ObjectAttributeMapping.h
//  ObjectAutoMapping
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectAttributeMapping : NSObject<NSCopying>

@property (nonatomic, copy) NSString *sourceKeyPath;

@property (nonatomic, copy) NSString *destinationKeyPath;

+ (ObjectAttributeMapping *)mappingFromKeyPath:(NSString *)sourceKeyPath toKeyPath:(NSString *)destinationKeyPath;

@end
