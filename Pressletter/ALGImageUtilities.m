//
//  ALGImageUtilities.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGImageUtilities.h"

@implementation ALGImageUtilities

+ (UIImage *)alphabetSheet:(CGSize)tileSize scale:(CGFloat)scale debug:(BOOL)debug {
    NSParameterAssert([NSThread isMainThread]);
    tileSize.width *= scale;
    tileSize.height *= scale;
    NSInteger numCols = 5;
    NSInteger numRows = ceilf(26. / 5.f);
    CGSize imageSize = CGSizeMake(tileSize.width * numCols, tileSize.height * numRows);
    NSArray *alphaArray = [ALGImageUtilities alphabetArray];

    CGFloat fontSize = 80.f;
    if (228.f == tileSize.width) {
        // iPad Retina
        fontSize = 160.f;
    } else if (64.f == tileSize.width) {
        // iPhone Non-Retina
        fontSize = 40.f;
    }
    
    UIFont *font = [UIFont fontWithName:@"MuseoSansRounded-700" size:fontSize];
    NSAssert(nil != font, @"Couldn't Get Font");
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // if (YES == debug) {
        // fill background with white
        CGContextSetRGBFillColor(ctx, 1.f, 1.f, 1.f, 1.f);
        CGContextFillRect(ctx, CGRectMake(0.f, 0.f, imageSize.width, imageSize.height));
    // }
    // set font color
    CGContextSetRGBFillColor(ctx, 0.f, 0.f, 0.f, 1.f);
    CGFloat yOffset = 8.f * scale;
    for (int ii = 0; ii < numRows; ++ii) {
        for (int jj = 0; jj < numCols; ++jj) {
            CGRect tileRect = CGRectMake(jj * tileSize.width, ii * tileSize.height + yOffset, tileSize.width, tileSize.height);
            NSString *letter = alphaArray[ii * numCols + jj];
            [letter drawInRect:tileRect withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
            if (YES == debug) {
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

+ (UIImage *)grayscaleImageForBytes:(unsigned char *)buf size:(CGSize)size error:(NSError **)error {
    NSParameterAssert(nil != buf);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              buf,
                                                              size.width * size.height,
                                                              NULL);
    if (nil == provider) {
        if (nil != *error) {
            *error = [NSError errorWithDomain:@"ALGErrorDomain" code:-255 userInfo:@{NSLocalizedDescriptionKey : @"Couldn't create data provider"}];
        }
        return nil;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(size.width,
                                        size.height,
                                        8,
                                        8,
                                        size.width, colorSpace,
                                        bitmapInfo,
                                        provider, NULL, NO, renderingIntent);
    if (nil == imageRef) {
        CGColorSpaceRelease(colorSpace);
        CGDataProviderRelease(provider);
        if (nil != *error) {
            *error = [NSError errorWithDomain:@"ALGErrorDomain" code:-255 userInfo:@{NSLocalizedDescriptionKey : @"Couldn't create CGImage"}];
        }
        return nil;
    }
    UIImage *retImg = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    return retImg;
}

+ (unsigned char *)thresholdDataForImage:(UIImage *)image colorData:(unsigned char **)colorData {
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    // now, threshold the entire image (we could save maybe a few cycles by only
    // thresholding the parts we're interested in)
    unsigned char *thresholdData = (unsigned char*)calloc(width * height, sizeof(unsigned char));
    memset(thresholdData, 255, width * height);

    unsigned char *rawPtr = rawData;
    unsigned char *threshPtr = thresholdData;
    for (int ii = 0; ii < height; ++ii) {
        for (int jj = 0; jj < width; ++jj) {
            int idx = (ii * width + jj) * 4;
            unsigned char r = rawPtr[idx++];
            unsigned char g = rawPtr[idx++];
            unsigned char b = rawPtr[idx++];
            __unused unsigned char a = rawPtr[idx++];
            if (r <= 52 && g <= 52 && b <= 52) {
                *threshPtr = 0;
            }
            threshPtr++;
        }
    }
    if (NULL != colorData) {
        *colorData = rawData;
    } else {
        free(rawData);
    }
    return thresholdData;
}

+ (unsigned char *)alphaDataForTileSize:(CGSize)size {
    NSString *fileName = [NSString stringWithFormat:@"alphaSheet_%d.png", (int)size.width];
    // we do this instead of `imageNamed` to work around loading assets in unit test bundles
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:nil];
    UIImage *alphaImage = [UIImage imageWithContentsOfFile:filePath];
    NSAssert(nil != alphaImage, @"Couldn't load alpha sheet: %@", fileName);
    CGImageRef imageRef = [alphaImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    unsigned char *rawData = (unsigned char*) calloc(height * width, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 1;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    return rawData;
}
@end
