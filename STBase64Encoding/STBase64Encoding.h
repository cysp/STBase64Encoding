//
//  STBase64Encoding.h
//  STBase64Encoding
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012 Scott Talbot.
//

#import <Foundation/Foundation.h>


extern NSString * const STBase64EncodingErrorDomain;
extern NSInteger const STBase64EncodingErrorUnknown;
extern NSInteger const STBase64EncodingErrorInvalidInput;


typedef NS_OPTIONS(NSUInteger, STBase64DecodingOptions) {
	STBase64DecodingOptionSkipInvalidInputBytes = 0b0001,
};


@interface STBase64Encoding : NSObject

+ (NSData *)dataByBase64EncodingData:(NSData *)data;
+ (NSString *)stringByBase64EncodingData:(NSData *)data;

+ (NSData *)dataByBase64DecodingString:(NSString *)string;
+ (NSData *)dataByBase64DecodingString:(NSString *)string withOptions:(STBase64DecodingOptions)options error:(NSError * __autoreleasing *)error;
+ (NSData *)dataByBase64DecodingData:(NSData *)data;
+ (NSData *)dataByBase64DecodingData:(NSData *)data withOptions:(STBase64DecodingOptions)options error:(NSError * __autoreleasing *)error;

@end
