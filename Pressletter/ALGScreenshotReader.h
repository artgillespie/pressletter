//
//  ALGScreenshotReader.h
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALGScreenshotReader : NSObject

- (id)initWithImage:(UIImage *)image;
- (BOOL)read;
- (NSString *)letterAtRow:(NSInteger)row column:(NSInteger)column;

@end
