//
//  ALGScreenshotReader.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGScreenshotReader.h"
#import "ALGImageUtilities.h"

unsigned char ALGDataForTile(unsigned char *buf, int tile, int x, int y, int side) {
    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * side * 5 * side;
    int tile_col_offs = tile_col * side;
    int row_offs = y * 5 * side + tile_row_offs;
    int col_offs = x + tile_col_offs;
    return buf[row_offs + col_offs];
}

ALGTileColor ALGColorForTile(unsigned char *buf, int tile, int side) {
    // sample the color at tile's 10, 10
    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * side * side * 5 * 4;
    int tile_col_offs = tile_col * side * 4;
    int row_offs = 10 * side * 4 + tile_row_offs;
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
    __strong UIImage *_croppedImage;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (nil != self) {
        _image = image;
    }
    return self;
}

- (BOOL)read {
    typedef enum {
        iPhone4,
        iPhone4Retina,
        iPhone5,
        iPadPortrait,
        iPadPortraitRetina,
        iPadLandscape,
        iPadLandscapeRetina
    } screenshotType;

    CGSize screenshotSize = _image.size;
    CGSize tileSize = CGSizeMake(64.f, 64.f);
    CGFloat scale = 2.f;
    screenshotType type = iPhone5;
    if (screenshotSize.width == 1024.f) {
        tileSize = CGSizeMake(114.f, 114.f);
        scale = 1.f;
        type = iPadLandscape;
    } else if (screenshotSize.height == 1024.f) {
        tileSize = CGSizeMake(114.f, 114.f);
        scale = 1.f;
        type = iPadPortrait;
    } else if (screenshotSize.width == 2048.f) {
        tileSize = CGSizeMake(114.f, 114.f);
        scale = 2.f;
        type = iPadLandscapeRetina;
    } else if (screenshotSize.height == 2048.f) {
        tileSize = CGSizeMake(114.f, 114.f);
        scale = 2.f;
        type = iPadPortraitRetina;
    } else if (screenshotSize.width == 320.f) {
        tileSize = CGSizeMake(64.f, 64.f);
        type = iPhone4;
        scale = 1.f;
    } else if (screenshotSize.height == 960.f) {
        tileSize = CGSizeMake(64.f, 64.f);
        type = iPhone4Retina;
        scale = 2.f;
    } else if (screenshotSize.height == 1136.f) {
        tileSize = CGSizeMake(64.f, 64.f);
        type = iPhone5;
        scale = 2.f;
    } else {
        NSLog(@"NOT A LETTERPRESS SCREENSHOT");
        return NO;
    }
    unsigned char *colorData = nil;
    // crop the screenshot appropriately
    CGFloat side = tileSize.width * scale * 5.f;
    CGRect cropRect = CGRectMake(0.f, screenshotSize.height - side, side, side);
    if (iPadPortrait == type || iPadPortraitRetina == type) {
        cropRect = CGRectMake(99.f * scale, 354.f * scale, side, side);
    } else if (iPadLandscape == type || iPadLandscapeRetina == type) {
        cropRect = CGRectMake(227.f * scale, 184.f * scale, side, side);
    }

    CGImageRef croppedCGImage = CGImageCreateWithImageInRect([_image CGImage], cropRect);
    _croppedImage = [UIImage imageWithCGImage:croppedCGImage];

    unsigned char *thresholdData = [ALGImageUtilities thresholdDataForImage:_croppedImage colorData:&colorData];
    UIImage *alphabetSheet = [ALGImageUtilities alphabetSheet:tileSize scale:scale debug:YES];
    unsigned char *alphaThreshold = [ALGImageUtilities thresholdDataForImage:alphabetSheet colorData:nil];

    NSString *docpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:docpath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSData *croppedData = UIImagePNGRepresentation(_croppedImage);
    [croppedData writeToFile:[docpath stringByAppendingPathComponent:@"croppedImage.png"] options:NSDataWritingAtomic error:nil];
    NSData *alphaSheet = UIImagePNGRepresentation(alphabetSheet);
    [alphaSheet writeToFile:[docpath stringByAppendingPathComponent:@"alphabetSheet.png"] options:NSDataWritingAtomic error:nil];
    [self writeGrayscaleBytes:thresholdData size:_croppedImage.size toPath:[docpath stringByAppendingPathComponent:@"thresholdData.png"] error:nil];
    [self writeGrayscaleBytes:alphaThreshold size:alphabetSheet.size toPath:[docpath stringByAppendingPathComponent:@"alphaSheet.png"] error:nil];

    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:25];
    NSInteger tileWidth = tileSize.width * scale;
    NSInteger tileHeight = tileSize.height * scale;
    for (int hh = 0; hh < 25; ++hh) { // tiles
        int high_corr = 0;
        int hit = 0;
        for (int ii = 0; ii < 26; ++ii) { // letters
            int corr = 0;
            for (int jj = 0; jj < tileHeight; ++jj) { // rows
                for (int kk = 0; kk < tileWidth; ++kk) { // cols
                    unsigned char a = ALGDataForTile(alphaThreshold, ii, kk, jj, tileWidth);
                    // slide the buffer pointer forward (down) to where the tiles start
                    unsigned char t = ALGDataForTile(thresholdData, hh, kk, jj, tileWidth);
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
        tile.tileColor = ALGColorForTile(colorData, hh, tileWidth);
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

- (UIImage *)croppedImage {
    return _croppedImage;
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
