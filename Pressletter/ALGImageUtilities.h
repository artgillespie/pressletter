//
//  ALGImageUtilities.h
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALGImageUtilities : NSObject

/*
 * Generates an alphaSheet
 */
+ (UIImage *)alphabetSheet:(CGSize)size scale:(CGFloat)scale debug:(BOOL)debug;
+ (unsigned char *)thresholdDataForImage:(UIImage *)image colorData:(unsigned char **)colorData;

/*
 * Loads a cached alphaSheet's threshold data. Returns nil if it can't find the correct sheet for
 * the tile size.
 */
+ (unsigned char *)alphaDataForTileSize:(CGSize)size;
+ (UIImage *)grayscaleImageForBytes:(unsigned char *)buf size:(CGSize)size error:(NSError **)error;

@end
