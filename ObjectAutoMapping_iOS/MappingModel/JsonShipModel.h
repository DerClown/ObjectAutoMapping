//
//  JsonShipModel.h
//  ObjectAutoMappingDemo_iOS
//
//  Created by Dong on 12/15/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectAutoMapping.h"
#import "RelationShipModel.h"

@interface JsonShipModel : ObjectAutoMapping

@property (nonatomic, copy) NSString *thumbImg;
@property (nonatomic, copy) NSArray *products;

@property (nonatomic, strong) RelationShipModel *shipModel;

@end
