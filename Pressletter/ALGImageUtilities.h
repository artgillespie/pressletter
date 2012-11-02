//
//  ALGImageUtilities.h
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALGImageUtilities : NSObject

+ (UIImage *)alphabetSheet:(BOOL)debug;
+ (unsigned char *)thresholdDataForImage:(UIImage *)image colorData:(unsigned char **)colorData;
+ (UIImage *)grayscaleImageForBytes:(unsigned char *)buf size:(CGSize)size error:(NSError **)error;

@end