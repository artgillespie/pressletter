//
//  ALGBoardView.h
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

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
