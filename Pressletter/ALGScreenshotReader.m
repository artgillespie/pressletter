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
    return NO;
}

- (NSString *)letterAtRow:(NSInteger)row column:(NSInteger)column {
    return nil;
}

@end
