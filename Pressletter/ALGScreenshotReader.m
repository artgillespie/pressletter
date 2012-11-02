//
//  ALGScreenshotReader.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGScreenshotReader.h"

typedef enum {
    ALGNonRetina = 0,
    ALGRetina,
    ALGiPhone5,
} ALGDimensions;

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
            if (r <= 52 && g <= 52 && b <= 52) {
                *threshPtr = 0;
            }
            threshPtr++;
        }
    }

    NSError *error = nil;
    if(NO == [self writeGrayscaleBytes:thresholdData size:CGSizeMake(width, height) toPath:@"/Users/artgillespie/Desktop/Pressletter.png" error:&error]) {
        NSAssert(NO, @"Couldn't write grayscale image: %@", error);
    }

    free(rawData);
    free(thresholdData);
    return YES;
}

- (ALGScreenshotReaderTile *)tileAtRow:(NSInteger)row column:(NSInteger)column {
    return nil;
}

#pragma mark - Private Debugging Methods

- (UIImage *)grayscaleImageForBytes:(unsigned char *)buf size:(CGSize)size error:(NSError **)error {
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
        if (nil != *error) {
            *error = [NSError errorWithDomain:@"ALGErrorDomain" code:-255 userInfo:@{NSLocalizedDescriptionKey : @"Couldn't create CGImage"}];
        }
        return nil;
    }
    return [UIImage imageWithCGImage:imageRef];
}

- (BOOL)writeGrayscaleBytes:(unsigned char *)buf size:(CGSize)size toPath:(NSString *)path error:(NSError **)error {
    NSParameterAssert(nil != buf);
    UIImage *grayscaleImage = [self grayscaleImageForBytes:buf size:size error:error];
    if (nil == grayscaleImage) {
        return NO;
    }
    NSData *data = UIImagePNGRepresentation(grayscaleImage);
    return [data writeToFile:path options:NSDataWritingAtomic error:error];
}

- (UIImage *)createImageForAlphabet {
    
}

@end
