//
//  ALGImageUtilities.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGImageUtilities.h"

@implementation ALGImageUtilities

+ (UIImage *)alphabetSheet {
    NSParameterAssert([NSThread isMainThread]);

    BOOL debugging = YES;
    
    CGSize tileSize = CGSizeMake(128.f, 128.f);
    NSInteger numCols = 5;
    NSInteger numRows = ceilf(26. / 5.f);
    CGSize imageSize = CGSizeMake(tileSize.width * numCols, tileSize.height * numRows);
    NSArray *alphaArray = [ALGImageUtilities alphabetArray];

    UIFont *font = [UIFont fontWithName:@"MuseoSansRounded-700" size:80.f];
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (YES == debugging) {
        // fill background with white
        CGContextSetRGBFillColor(ctx, 1.f, 1.f, 1.f, 1.f);
        CGContextFillRect(ctx, CGRectMake(0.f, 0.f, imageSize.width, imageSize.height));
    }
    // set font color
    CGContextSetRGBFillColor(ctx, 0.f, 0.f, 0.f, 1.f);
    CGFloat yOffset = 16.f;
    for (int ii = 0; ii < numRows; ++ii) {
        for (int jj = 0; jj < numCols; ++jj) {
            CGRect tileRect = CGRectMake(jj * tileSize.width, ii * tileSize.height + yOffset, tileSize.width, tileSize.height);
            NSString *letter = alphaArray[ii * numCols + jj];
            [letter drawInRect:tileRect withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
            if (YES == debugging) {
                // stroke each tile's rectangle so we can eyeball alignment in an overlay
                CGContextSaveGState(ctx);
                CGContextSetRGBStrokeColor(ctx, 1.f, 0.f, 0.f, 0.5f);
                CGContextStrokeRect(ctx, CGRectMake(jj * tileSize.width, ii * tileSize.height, tileSize.width, tileSize.height));
                CGContextRestoreGState(ctx);
            }
            if (25 == ii * numCols + jj)
                break;
        }
    }
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

+ (NSArray *)alphabetArray {
    NSMutableArray *alphaArray = [NSMutableArray arrayWithCapacity:26];
    for (unichar ii = 'A'; ii <= 'Z'; ++ii) {
        [alphaArray addObject:[NSString stringWithCharacters:&ii length:1]];
    }
    return [NSArray arrayWithArray:alphaArray];
}

@end
