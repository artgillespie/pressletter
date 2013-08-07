//
//  ALGScreenshotReader.h
//  Pressletter
//
//  Copyright (C) 2012, 2013  Art Gillespie
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.//

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

@property (nonatomic, readonly) UIImage *croppedImage;

- (id)initWithImage:(UIImage *)image;
- (BOOL)read;
- (ALGScreenshotReaderTile *)tileAtRow:(NSInteger)row column:(NSInteger)column;
- (NSString *)stringForTiles;

@end
