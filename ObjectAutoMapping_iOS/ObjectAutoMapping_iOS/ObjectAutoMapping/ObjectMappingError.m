//
//  ObjectMappingError.m
//  ObjectAutoMapping
//
//  Created by Dong on 12/13/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "ObjectMappingError.h"

NSString* const ObjectMappingErrorDomain        = @"ObjectMappingErrorDomain";
NSString* const kObjectMappingTypeMismatch      = @"kObjectMappingTypeMismatch";

@implementation ObjectMappingError

+ (id)errorInvalidDataWithMessage:(NSString *)message {
    message = [NSString stringWithFormat:@"Invalid input data: %@", message];
    return [ObjectMappingError errorWithDomain:ObjectMappingErrorDomain
                                      code:kObjectMappingErrorInvalidSourceData
                                  userInfo:@{NSLocalizedDescriptionKey:message}];
}

+ (id)errorWithObjectMappingMismatch:(NSString *)mismatchDescription {
    return [ObjectMappingError errorWithDomain:ObjectMappingErrorDomain
                                      code:kObjectMappingErrorObjectMappingMismatch
                                  userInfo:@{NSLocalizedDescriptionKey:@"Target class object and input data mapping are in disagreement. Check the error user information.",kObjectMappingTypeMismatch:mismatchDescription}];
}

+ (id)errorWithUnMappableContent {
    return [ObjectMappingError errorWithDomain:ObjectMappingErrorDomain
                                          code:kObjectMappingErrorUnMappableContent
                                      userInfo:@{NSLocalizedDescriptionKey:@"No mappable attributes or ralationships not found."}];
}

+ (id)errorMappingModelIsInvalid {
    return [ObjectMappingError errorWithDomain:ObjectMappingErrorDomain
                                      code:kObjectMappingErrorModelIsInvalid
                                  userInfo:@{NSLocalizedDescriptionKey:@"Model dose not kind of 'ObjectAutoMapping' class. The custom validation for the input data failed."}];
}

@end
