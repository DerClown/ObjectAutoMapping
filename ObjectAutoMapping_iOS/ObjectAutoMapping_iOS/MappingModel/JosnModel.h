//
//  JosnModel.h
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAutoMapping.h"

@class ContainshipModel;

@interface JosnModel : ObjectAutoMapping

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, strong) NSArray *avatar;

@end
