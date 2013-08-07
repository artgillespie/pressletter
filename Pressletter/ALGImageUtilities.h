//
//  ALGImageUtilities.h
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

@interface ALGImageUtilities : NSObject

/*
 * Generates an alphaSheet
 */
+ (UIImage *)alphabetSheet:(CGSize)size scale:(CGFloat)scale debug:(BOOL)debug;
+ (unsigned char *)thresholdDataForImage:(UIImage *)image tileSize:(CGSize)tileSize colorData:(unsigned char **)colorData;

/*
 * Loads a cached alphaSheet's threshold data. Returns nil if it can't find the correct sheet for
 * the tile size.
 */
+ (unsigned char *)alphaDataForTileSize:(CGSize)size;
+ (UIImage *)grayscaleImageForBytes:(unsigned char *)buf size:(CGSize)size error:(NSError **)error;

@end
