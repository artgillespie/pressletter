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

ALGTileColor ALGColorForTile(unsigned char *buf, int tile) {
    // sample the color at tile's 10, 10
    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * 128 * 640 * 4;
    int tile_col_offs = tile_col * 128 * 4;
    int row_offs = 10 * 640 * 4 + tile_row_offs;
    int col_offs = 10 * 4 + tile_col_offs;
    unsigned char r = buf[row_offs + col_offs];
    unsigned char g = buf[row_offs + col_offs + 1];
    unsigned char b = buf[row_offs + col_offs + 2];
    if (r > 210 && g > 210 && b > 210) {
        return ALGTileColorWhite;
    } else if (r > 110 && r < 130 && g > 190 && g < 210 && b > 235 && b < 255) {
        return ALGTileColorBlue;
    } else if (r < 10 && g > 149 && g < 169 && b > 241) {
        return ALGTileColorDarkBlue;
    } else if (r > 237 && r < 257 && g > 143 && g < 163 && b > 131 && b < 151) {
        return ALGTileColorRed;
    } else if (r > 245 && g > 57 && g < 77 && b > 37 && b < 57) {
        return ALGTileColorDarkRed;
    } else {
        NSLog(@"DON'T RECOGNIZE TILE COLOR!!! %d, %d, %d", r, g, b);
    }
    // 120, 200, 245 == light blue
    // 0, 159, 251 == dark blue
    // 233, 232, 229 == white
    // 247, 153, 141 == light red
    // 255, 67, 47 == dark red
    return 0;
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

    unsigned char *colorData = nil;
    unsigned char *thresholdData = [ALGImageUtilities thresholdDataForImage:_image colorData:&colorData];
    unsigned char *alphaThreshold = [ALGImageUtilities thresholdDataForImage:[ALGImageUtilities alphabetSheet:NO] colorData:nil];

    NSString *docpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:docpath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // [self writeGrayscaleBytes:thresholdData size:_image.size toPath:[docpath stringByAppendingPathComponent:@"thresholdData.png"] error:nil];
    // [self writeGrayscaleBytes:alphaThreshold size:_image.size toPath:[docpath stringByAppendingPathComponent:@"alphaSheet.png"] error:nil];

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
            for (int jj = 30; jj < 80; ++jj) { // rows
                for (int kk = 30; kk < 80; ++kk) { // cols
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
        // tile offset * 4 to account for rgba bytes
        tile.tileColor = ALGColorForTile(colorData + tileOffset * 4, hh);
        [tmp addObject:tile];
    }
    _tiles = [NSArray arrayWithArray:tmp];
    free(colorData);
    free(thresholdData);
    return YES;
}

- (ALGScreenshotReaderTile *)tileAtRow:(NSInteger)row column:(NSInteger)column {
    NSParameterAssert(row * 5 + column < [_tiles count]);
    return _tiles[row * 5 + column];
}

- (NSString *)stringForTiles {
    NSMutableString *retString = [NSMutableString stringWithCapacity:25];
    for (ALGScreenshotReaderTile *tile in _tiles) {
        [retString appendString:tile.letter];
    }
    return [NSString stringWithString:retString];
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
