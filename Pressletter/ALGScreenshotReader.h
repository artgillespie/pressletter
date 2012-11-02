//
//  ALGScreenshotReader.h
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ALGTileColorWhite = 0,
    ALGTileColorRed,
    ALGTileColorDarkRed,
    ALGTileColorBlue,
    ALGTileColorDarkBlue
} ALGTileColor;

@interface ALGScreenshotReaderTile : NSObject

@property (nonatomic, assign) ALGTileColor tileColor;
@property (nonatomic, strong) NSString *letter;

@end

@interface ALGScreenshotReader : NSObject

- (id)initWithImage:(UIImage *)image;
- (BOOL)read;
- (ALGScreenshotReaderTile *)tileAtRow:(NSInteger)row column:(NSInteger)column;

@end
