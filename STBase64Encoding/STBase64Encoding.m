//
//  STBase64Encoding.m
//  STBase64Encoding
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012 Scott Talbot.
//

#import "STBase64Encoding.h"


NSString * const STBase64EncodingErrorDomain = @"STBase64Encoding";
NSInteger const STBase64EncodingErrorUnknown = 0;
NSInteger const STBase64EncodingErrorInvalidInput = 1;


static const char stbase64_table[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
	'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};


typedef NS_ENUM(NSUInteger, STBase64EncodingReturnType) {
	STBase64EncodingReturnTypeData = 0,
	STBase64EncodingReturnTypeString,
};


@implementation STBase64Encoding {
}

#pragma mark - Encoding

+ (NSData *)dataByBase64EncodingData:(NSData *)data {
	return [self _st_objectOfType:STBase64EncodingReturnTypeData byBase64EncodingData:data];
}

+ (NSString *)stringByBase64EncodingData:(NSData *)data {
	return [self _st_objectOfType:STBase64EncodingReturnTypeString byBase64EncodingData:data];
}

+ (id)_st_objectOfType:(STBase64EncodingReturnType)returnType byBase64EncodingData:(NSData *)data {
	const char *inputBytes = [data bytes];
	NSUInteger inputLength = [data length];

	NSUInteger encodedLength = ((inputLength + 2) / 3) * 4;
	char *encoded = malloc(encodedLength);
	if (!encoded) {
		return nil;
	}

	for (NSUInteger i = 0; i < inputLength; i += 3) {
		NSUInteger accum = 0;
		for (NSUInteger j = 0; j < 3; ++j) {
			accum <<= 8;
			if (i + j < inputLength) {
				accum |= inputBytes[i + j] & 0xff;
			}
		}

		NSUInteger ix = (i / 3) * 4;
		encoded[ix + 0] =                       stbase64_table[(accum >> 18) & 0x3f];
		encoded[ix + 1] =                       stbase64_table[(accum >> 12) & 0x3f];
		encoded[ix + 2] = i + 1 < inputLength ? stbase64_table[(accum >>  6) & 0x3f] : '=';
		encoded[ix + 3] = i + 2 < inputLength ? stbase64_table[(accum >>  0) & 0x3f] : '=';
	}

	switch (returnType) {
		default:
		case STBase64EncodingReturnTypeData: {
			return [[NSData alloc] initWithBytesNoCopy:encoded length:encodedLength freeWhenDone:YES];
		} break;
		case STBase64EncodingReturnTypeString: {
			return [[NSString alloc] initWithBytesNoCopy:encoded length:encodedLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
		} break;
	}
}


#pragma mark - Decoding

+ (NSData *)dataByBase64DecodingString:(NSString *)string {
	return [self dataByBase64DecodingString:string error:NULL];
}
+ (NSData *)dataByBase64DecodingString:(NSString *)string error:(NSError *__autoreleasing *)error {
	NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
	if (!data) {
		if (error) {
			*error = [NSError errorWithDomain:STBase64EncodingErrorDomain code:STBase64EncodingErrorInvalidInput userInfo:nil];
		}
		return nil;
	}

	return [self dataByBase64DecodingData:data error:error];
}

+ (NSData *)dataByBase64DecodingData:(NSData *)data {
	return [self dataByBase64DecodingData:data error:NULL];
}
+ (NSData *)dataByBase64DecodingData:(NSData *)data error:(NSError * __autoreleasing *)error {
	NSError *localError = nil;

	const char *inputBytes = [data bytes];
	NSUInteger inputLength = [data length];
	NSUInteger expectedLength = inputLength * 3 / 4;
	NSUInteger decodedLength = 0;
	char *decoded = NULL;

	do {
		if (inputLength % 4) {
			localError = [NSError errorWithDomain:STBase64EncodingErrorDomain code:STBase64EncodingErrorInvalidInput userInfo:nil];
			break;
		}

		decoded = malloc(expectedLength);
		if (!decoded) {
			localError = [NSError errorWithDomain:STBase64EncodingErrorDomain code:STBase64EncodingErrorUnknown userInfo:nil];
			break;
		}

		NSUInteger accum = 0;
		NSUInteger sextetsInAccum = 0;
		NSUInteger paddingBytesEncountered = 0;
		for (NSUInteger i = 0; i < inputLength; ++i) {
			char inputByte = inputBytes[i];

			if (inputByte == '=') {
				if (paddingBytesEncountered < 2) {
					accum <<= 6;
					++paddingBytesEncountered;
				}
				continue;
			}

			accum <<= 6;
			++sextetsInAccum;

			if (paddingBytesEncountered > 0) {
				localError = [NSError errorWithDomain:STBase64EncodingErrorDomain code:STBase64EncodingErrorInvalidInput userInfo:nil];
				break;
			}
			if (inputByte >= 'A' && inputByte <= 'Z') {
				accum |= (NSUInteger)(inputByte - 'A') & 0x3f;
			} else if (inputByte >= 'a' && inputByte <= 'z') {
				accum |= (NSUInteger)((inputByte - 'a') + 26) & 0x3f;
			} else if (inputByte >= '0' && inputByte <= '9') {
				accum |= (NSUInteger)((inputByte - '0') + 52) & 0x3f;
			} else if (inputByte == '+') {
				accum |= 62;
			} else if (inputByte == '/') {
				accum |= 63;
			}

			if (sextetsInAccum == 4) {
				decoded[decodedLength++] = (char)(accum >> 16);
				decoded[decodedLength++] = (char)(accum >>  8);
				decoded[decodedLength++] = (char)(accum >>  0);
				sextetsInAccum = 0;
			}
		}

		if (sextetsInAccum > 0) {
			decoded[decodedLength] = (char)(accum >> 16);
		}
		if (sextetsInAccum > 1) {
			decoded[++decodedLength] = (char)(accum >>  8);
		}
		if (sextetsInAccum > 2) {
			decoded[++decodedLength] = 0;
		}
	} while (0);

	if (localError) {
		free(decoded);
		if (error) {
			*error = localError;
		}
		return nil;
	}

	return [[NSData alloc] initWithBytesNoCopy:decoded length:decodedLength freeWhenDone:YES];
}

@end
