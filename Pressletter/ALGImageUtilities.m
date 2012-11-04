//
//  ALGImageUtilities.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGImageUtilities.h"

// set grayscale byte at tile's x, y given tile of size (side, side)
void ALGSetDataForTile(unsigned char *buf, int tile, int x, int y, int side, unsigned char val) {
    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * side * 5 * side;
    int tile_col_offs = tile_col * side;
    int row_offs = y * 5 * side + tile_row_offs;
    int col_offs = x + tile_col_offs;
    buf[row_offs + col_offs] = val;
}

// returns grayscale for point in tile
unsigned char ALGGrayscaleForTileAtPoint(unsigned char *buf, int tile, int x, int y, int side) {
    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * side * side * 5 * 4;
    int tile_col_offs = tile_col * side * 4;
    int row_offs = y * side * 4 * 5 + tile_row_offs;
    int col_offs = x * 4 + tile_col_offs;
    unsigned char r = buf[row_offs + col_offs];
    unsigned char g = buf[row_offs + col_offs + 1];
    unsigned char b = buf[row_offs + col_offs + 2];
    return (r + g + b) / 3;
}

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

+ (unsigned char *)thresholdDataForImage:(UIImage *)image tileSize:(CGSize)tileSize colorData:(unsigned char **)colorData {
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

    for (int hh = 0; hh < 25; ++hh) {
        int avgAccumulator = 0;
        unsigned char bg_avg = 0;
        for (int ii = 0; ii < tileSize.height; ++ii) {
            for (int jj = 0; jj < tileSize.width; ++jj) {
                unsigned char gs = ALGGrayscaleForTileAtPoint(rawData, hh, jj, ii, tileSize.width);
                if (1 >= ii) {
                    avgAccumulator += gs;
                } else {
                    if (bg_avg < 50 && gs > 80) {
                        ALGSetDataForTile(thresholdData, hh, jj, ii, tileSize.width, 0);
                    } else if (bg_avg > 200 && gs < 170) {
                        ALGSetDataForTile(thresholdData, hh, jj, ii, tileSize.width, 0);
                    } else if (gs > bg_avg + 30 || gs < bg_avg - 30) {
                        ALGSetDataForTile(thresholdData, hh, jj, ii, tileSize.width, 0);
                    }
                }
            }
            if (1 == ii) {
                bg_avg = avgAccumulator / (2 * tileSize.width);
            }
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
