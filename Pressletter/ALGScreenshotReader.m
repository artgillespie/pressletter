//
//  ALGScreenshotReader.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGScreenshotReader.h"
#import "ALGImageUtilities.h"

// get byte at tile's x, y given tile of size (side, side)
unsigned char ALGDataForTile(unsigned char *buf, int tile, int x, int y, int side) {
    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * side * 5 * side;
    int tile_col_offs = tile_col * side;
    int row_offs = y * 5 * side + tile_row_offs;
    int col_offs = x + tile_col_offs;
    return buf[row_offs + col_offs];
}

// sample tile color given tile of size (side, side)
ALGTileColor ALGColorForTile(unsigned char *buf, int tile, int side) {

    int sampleAt = 20;
    if (64 == side) {
        sampleAt = 10;
    }

    int tile_row = tile / 5;
    int tile_col = tile % 5;
    int tile_row_offs = tile_row * side * side * 5 * 4;
    int tile_col_offs = tile_col * side * 4;
    int row_offs = sampleAt * side * 4 + tile_row_offs;
    int col_offs = sampleAt * 4 + tile_col_offs;
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
    iPhone4,
    iPhone4Retina,
    iPhone5,
    iPadPortrait,
    iPadPortraitRetina,
    iPadLandscape,
    iPadLandscapeRetina
} screenshotType;

@implementation ALGScreenshotReaderTile

@end

@implementation ALGScreenshotReader {
    __strong UIImage *_image;
    __strong NSArray *_tiles;
    __strong UIImage *_croppedImage;
    screenshotType _type;
    CGFloat _scale;
    CGSize _tileSize;
    CGFloat _side;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (nil != self) {
        _image = image;
        [self setup];
    }
    return self;
}

- (void)setup {
    CGSize screenshotSize = _image.size;
    _scale = 2.f;
    _type = iPhone5;
    if (screenshotSize.width == 1024.f) {
        _tileSize = CGSizeMake(114.f, 114.f);
        _scale = 1.f;
        _type = iPadLandscape;
    } else if (screenshotSize.height == 1024.f) {
        _tileSize = CGSizeMake(114.f, 114.f);
        _scale = 1.f;
        _type = iPadPortrait;
    } else if (screenshotSize.width == 2048.f) {
        _tileSize = CGSizeMake(114.f, 114.f);
        _scale = 2.f;
        _type = iPadLandscapeRetina;
    } else if (screenshotSize.height == 2048.f) {
        _tileSize = CGSizeMake(114.f, 114.f);
        _scale = 2.f;
        _type = iPadPortraitRetina;
    } else if (screenshotSize.width == 320.f) {
        _tileSize = CGSizeMake(64.f, 64.f);
        _type = iPhone4;
        _scale = 1.f;
    } else if (screenshotSize.height == 960.f) {
        _tileSize = CGSizeMake(64.f, 64.f);
        _type = iPhone4Retina;
        _scale = 2.f;
    } else if (screenshotSize.height == 1136.f) {
        _tileSize = CGSizeMake(64.f, 64.f);
        _type = iPhone5;
        _scale = 2.f;
    } else {
        // TODO: We should just bail out here.
        NSLog(@"NOT A LETTERPRESS SCREENSHOT");
    }
    // crop the screenshot appropriately
    _side = _tileSize.width * _scale * 5.f;
    CGRect cropRect = CGRectMake(0.f, screenshotSize.height - _side, _side, _side);
    if (iPadPortrait == _type || iPadPortraitRetina == _type) {
        cropRect = CGRectMake(99.f * _scale, 354.f * _scale, _side, _side);
    } else if (iPadLandscape == _type || iPadLandscapeRetina == _type) {
        cropRect = CGRectMake(227.f * _scale, 184.f * _scale, _side, _side);
    }

    CGImageRef croppedCGImage = CGImageCreateWithImageInRect([_image CGImage], cropRect);
    _croppedImage = [UIImage imageWithCGImage:croppedCGImage];
    CGImageRelease(croppedCGImage);
}

- (BOOL)read {

    unsigned char *colorData = nil;

    unsigned char *thresholdData = [ALGImageUtilities thresholdDataForImage:_croppedImage tileSize:CGSizeMake(_tileSize.width * _scale, _tileSize.height * _scale) colorData:&colorData];

    // This is how you generate alphabet sheets
    // UIImage *alphabetSheet = [ALGImageUtilities alphabetSheet:tileSize scale:scale debug:YES];
    // unsigned char *alphaThreshold = [ALGImageUtilities thresholdDataForImage:alphabetSheet colorData:nil];

    unsigned char *alphaThreshold = [ALGImageUtilities alphaDataForTileSize:CGSizeMake(_tileSize.width * _scale, _tileSize.height * _scale)];

    // useful for debugging: write out images to Documents directory
    NSString *docpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:docpath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // NSData *croppedData = UIImagePNGRepresentation(_croppedImage);
    // [croppedData writeToFile:[docpath stringByAppendingPathComponent:@"croppedImage.png"] options:NSDataWritingAtomic error:nil];
    [self writeGrayscaleBytes:thresholdData size:_croppedImage.size toPath:@"/Users/artgillespie/Desktop/thresholdData.png" error:nil];
    // [self writeGrayscaleBytes:alphaThreshold size:CGSizeMake(tileSize.width * scale * 5.f, tileSize.height * scale * 6.f) toPath:[docpath stringByAppendingPathComponent:@"alphaSheet.png"] error:nil];
    // [self writeGrayscaleCache:alphaThreshold size:alphabetSheet.size toPath:[docpath stringByAppendingPathComponent:[NSString stringWithFormat:@"alpha_%d.thrsh", (int)(tileSize.width * scale)]] error:nil];

    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:25];
    NSInteger tileWidth = _tileSize.width * _scale;
    NSInteger tileHeight = _tileSize.height * _scale;
    for (int hh = 0; hh < 25; ++hh) { // tiles
        int high_corr = 0;
        int hit = 0;
        for (int ii = 0; ii < 26; ++ii) { // letters
            int corr = 0;
            for (int jj = 20; jj < tileHeight - 20; jj += 2) { // rows
                for (int kk = 20; kk < tileWidth - 20; kk += 2) { // cols
                    unsigned char a = ALGDataForTile(alphaThreshold, ii, kk, jj, tileWidth);
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
        // TOOD: [alg] When we added support for all themes, this pretty much
        // became useless. Have to revisit color. Tedious!
        // tile.tileColor = ALGColorForTile(colorData, hh, tileWidth);
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

- (BOOL)writeGrayscaleCache:(unsigned char *)buf size:(CGSize)size toPath:(NSString *)path error:(NSError **)error {
    NSParameterAssert(nil != buf);
    NSData *data = [NSData dataWithBytes:buf length:size.width * size.height];
    return [data writeToFile:path options:NSDataWritingAtomic error:error];
}

@end
