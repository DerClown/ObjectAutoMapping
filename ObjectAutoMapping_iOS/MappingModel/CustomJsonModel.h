//
//  CustomJsonModel.h
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/15/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAutoMapping.h"

@interface CustomJsonModel : ObjectAutoMapping

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *country;

@property (nonatomic, copy) NSString *zone;
@property (nonatomic, copy) NSString *sign;

@property (nonatomic, strong) NSArray *otherInfos;

@property (nonatomic, strong) NSSet *sudents;

@property (nonatomic, strong) NSOrderedSet *otherSet;

@end
