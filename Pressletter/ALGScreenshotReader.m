//
//  ALGScreenshotReader.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGScreenshotReader.h"
#import "ALGImageUtilities.h"

unsigned char ALGDataForTile(unsigned char *buf, int tile, int x, int y) {
    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * 128 * 640;
    int tile_col_offs = tile_col * 128;
    int row_offs = y * 640 + tile_row_offs;
    int col_offs = x + tile_col_offs;
    return buf[row_offs + col_offs];
}

typedef enum {
    ALGNonRetina = 0,
    ALGRetina,
    ALGiPhone5,
} ALGDimensions;

@implementation ALGScreenshotReaderTile

@end

@implementation ALGScreenshotReader {
    __strong UIImage *_image;
    __strong NSArray *_tiles;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (nil != self) {
        _image = image;
    }
    return self;
}

- (BOOL)read {
    unsigned char *thresholdData = [ALGImageUtilities thresholdDataForImage:_image];
    unsigned char *alphaThreshold = [ALGImageUtilities thresholdDataForImage:[ALGImageUtilities alphabetSheet:NO]];

    long tileOffset = 640 * 320;
    if (1136.f == _image.size.height) {
        tileOffset = 640 * (1136 - 640);
    }

    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:25];
    for (int hh = 0; hh < 25; ++hh) { // tiles
        int high_corr = 0;
        int hit = 0;
        for (int ii = 0; ii < 26; ++ii) { // letters
            int corr = 0;
            for (int jj = 0; jj < 128; ++jj) { // rows
                for (int kk = 0; kk < 128; ++kk) { // cols
                    unsigned char a = ALGDataForTile(alphaThreshold, ii, kk, jj);
                    // slide the buffer pointer forward (down) to where the tiles start
                    unsigned char t = ALGDataForTile(thresholdData + tileOffset, hh, kk, jj);
                    if (a == t) {
                        corr++;
                    }
                }
            }
            if (corr > high_corr) {
                high_corr = corr;
                hit = ii;
            }
        }
        ALGScreenshotReaderTile *tile = [[ALGScreenshotReaderTile alloc] init];
        unichar hitChar = 'A' + hit;
        tile.letter = [NSString stringWithCharacters:&hitChar length:1];
        NSLog(@"LETTER: %@", tile.letter);
        [tmp addObject:tile];
    }
    _tiles = [NSArray arrayWithArray:tmp];
    free(thresholdData);
    return YES;
}

- (ALGScreenshotReaderTile *)tileAtRow:(NSInteger)row column:(NSInteger)column {
    NSParameterAssert(row * 5 + column < [_tiles count]);
    return _tiles[row * 5 + column];
}

#pragma mark - Private Debugging Methods


- (BOOL)writeGrayscaleBytes:(unsigned char *)buf size:(CGSize)size toPath:(NSString *)path error:(NSError **)error {
    NSParameterAssert(nil != buf);
    UIImage *grayscaleImage = [ALGImageUtilities grayscaleImageForBytes:buf size:size error:error];
    if (nil == grayscaleImage) {
        return NO;
    }
    NSData *data = UIImagePNGRepresentation(grayscaleImage);
    return [data writeToFile:path options:NSDataWritingAtomic error:error];
}

@end
