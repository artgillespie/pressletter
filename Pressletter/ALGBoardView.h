//
//  ALGBoardView.h
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

#import <UIKit/UIKit.h>

@class ALGScreenshotReader;
@class ALGBoardView;

@protocol ALGBoardViewDelegate <NSObject>

@required

- (void)boardViewDidChangeTileSelection:(ALGBoardView *)boardView;

@end

@interface ALGBoardView : UIView

@property (nonatomic, strong) ALGScreenshotReader *screenshotReader;
@property (nonatomic, strong) NSString *hitWord;
@property (nonatomic, strong) UIImage *boardImage;
// array of booleans indicating whether the tile is toggled
// TODO: [alg] why not a CFMutableBitVector?
@property (nonatomic, strong) NSMutableArray *selectedTiles;
@property (nonatomic, weak) id<ALGBoardViewDelegate> delegate;
@property (nonatomic, strong) NSString *selectedString;

@end
