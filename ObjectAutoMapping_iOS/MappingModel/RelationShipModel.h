//
//  RelationShipModel.h
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/15/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAutoMapping.h"

@interface RelationShipModel : ObjectAutoMapping

@property (nonatomic, assign) NSInteger uniqueId;

@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;

@end
