//
//  ALGScreenshotReader.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGScreenshotReader.h"

@implementation ALGScreenshotReader {
    __strong UIImage *_image;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (nil != self) {
        _image = image;
    }
    return self;
}

- (BOOL)read {
    // First get the image into your data buffer
    CGImageRef imageRef = [_image CGImage];
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
    unsigned char *thresholdData = (unsigned char*)calloc(height * width, sizeof(unsigned char));
    memset(thresholdData, 255, height * width);

    unsigned char *rawPtr = rawData;
    unsigned char *threshPtr = thresholdData;
    for (int ii = 0; ii < height; ++ii) {
        for (int jj = 0; jj < width; ++jj) {
            unsigned char r = *rawPtr++;
            unsigned char g = *rawPtr++;
            unsigned char b = *rawPtr++;
            __unused unsigned char a = *rawPtr++;
            if (r <= 50 && g <= 50 && b <= 50) {
                *threshPtr = 0;
            }
            threshPtr++;
        }
    }

    free(rawData);
    free(thresholdData);
    return YES;
}

- (ALGScreenshotReaderTile *)tileAtRow:(NSInteger)row column:(NSInteger)column {
    return nil;
}

@end
