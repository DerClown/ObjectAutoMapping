//
//  ObjectMappingError.h
//  ObjectAutoMapping
//
//  Created by Dong on 12/13/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, kObjectMappingErrorTypes)
{
    kObjectMappingErrorInvalidSourceData     = -10000,
    kObjectMappingErrorObjectMappingMismatch = -10001,
    kObjectMappingErrorUnMappableContent     = -10002,
    kObjectMappingErrorModelIsInvalid        = -10003,
};

/////////////////////////////////////////////////////////////////////////////////////////////
/** The domain name used for the ObjectMappingError instances */
extern NSString* const ObjectMappingErrorDomain;

/**
 *  If the source data input not found, check the userInfo
 *  dictionary of the ObjectMappingError instance you get back -
 *  under the kObjectMappingErrorInvalidSourceData key you will
 *  find a description of the source data.
 */
extern NSString* const ObjectMappingInvalidSourceData;

/**
 * If Mapping input has a different type than expected by the model, check the
 * userInfo dictionary of the ObjectMappingError instance you get back -
 * under the kObjectMappingTypeMismatch key you will find a description
 * of the mismatched types.
 */
extern NSString* const kObjectMappingTypeMismatch;

@interface ObjectMappingError : NSError

/**
 * Creates a ObjectMappingError instance with code kObjectMappingErrorInvalidData = -10000
 */
+ (id)errorInvalidDataWithMessage:(NSString *)message;

/**
 * Creates a ObjectMappingError instance with code kObjectMappingErrorObjectMappingMismatch = -10001
 * @param A description of the type mismatch that was encountered.
 */
+ (id)errorWithObjectMappingMismatch:(NSSet *)keys;

/**
 * Creates a ObjectMappingError instance with code kObjectMappingErrorUnMappableContent = -10002
 * @param A description of the type unmappable content that was encountered.
 */
+ (id)errorWithUnMappableContent;

/**
 * Creates a ObjectMappingError instance with code kObjectMappingErrorModelIsInvalid = -10003
 */
+ (id)errorMappingModelIsInvalid;

@end
