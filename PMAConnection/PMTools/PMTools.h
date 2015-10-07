//
//  PMTools.h
//  PMTests
//
//  Created by Poslovanje Kvadrat on 17.02.2015..
//  Copyright (c) 2015. Poslovanje Kvadrat. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Base64.h"

@interface PMTools :NSObject


// HELPING ADDITIONAL METHODS

#pragma mark encoding operation

-(NSString *)md5:(NSString *)input;
-(NSString *)encodeImageToBase64: (UIImage *)image;
-(NSString *)encodeStringToBase64: (NSString *)string;
-(NSString *)generateRandomStringWithLenght:(int)lenght;

#pragma mark image operations

-(UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)sourceImage;
-(UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original;

#pragma mark validation operations

-(BOOL)isValidEmail:(NSString *)emailStr;
-(BOOL)isValidPhoneNumber;



@end
