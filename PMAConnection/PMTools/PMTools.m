//
//  PMTools.m
//  PMTests
//
//  Created by Poslovanje Kvadrat on 17.02.2015..
//  Copyright (c) 2015. Poslovanje Kvadrat. All rights reserved.
//

#import "PMTools.h"

@implementation PMTools

#pragma mark encoding operation

- (NSString *)md5:(NSString *)input{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}


-(NSString *)encodeImageToBase64: (UIImage *)image{
    NSData* imagedata = UIImageJPEGRepresentation(image, 0.5f);
    NSString *imageencoded = [Base64 encode:imagedata];
    imageencoded = [imageencoded stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]; // WHY APPLE WHY???
    return imageencoded;
}

-(NSString *)encodeStringToBase64: (NSString *)string{
    NSData* stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [Base64 encode:stringData];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return encodedString;
}

-(NSString *)generateRandomStringWithLenght:(int)lenght{

    NSString *stringsArray = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: lenght];
    
    for (int i=0; i<lenght; i++) {
        [randomString appendFormat: @"%C", [stringsArray characterAtIndex: arc4random_uniform([stringsArray length])]];
    }
    return randomString;
}

#pragma mark image operations


- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original
{
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius] addClip];
    [original drawInRect:frame];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark validation operations

- (BOOL)isValidEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

- (BOOL) isValidPhoneNumber
{
    NSString * regex = @"^(\\+?)(\\d{13})$";
    NSPredicate *testPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL validationResult = [testPredicate evaluateWithObject: self];
    return validationResult;
}



@end
