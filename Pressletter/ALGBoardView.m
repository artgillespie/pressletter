//
//  ALGBoardView.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGBoardView.h"
#import "ALGScreenshotReader.h"

@implementation ALGBoardView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
        
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapRecognizer];
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:25];
    for (int ii = 0; ii < 25; ++ii) {
        tmp[ii] = @(NO);
    }
    _selectedTiles = tmp;
}

- (void)drawRect:(CGRect)rect {
    // draw the board as the background
    [self.boardImage drawInRect:self.bounds];
    if (nil == _screenshotReader) {
        return;
    }
    BOOL debugDraw = NO;
    CGFloat scale = [UIScreen mainScreen].scale;
    for (int ii = 0; ii < 5; ++ii) { // rows
        for (int jj = 0; jj < 5; ++jj) {
            CGRect tileRect = CGRectMake(jj * 64.f, ii * 64.f, 64.f, 64.f);
            CGRect insetRect = CGRectInset(tileRect, 3.f * scale, 3.f * scale);
            ALGScreenshotReaderTile *tile = [_screenshotReader tileAtRow:ii column:jj];
            if (YES == debugDraw) {
                [[UIColor blackColor] set];
                [tile.letter drawInRect:tileRect withFont:[UIFont boldSystemFontOfSize:14.f]];
                switch (tile.tileColor) {
                    case ALGTileColorBlue:
                        [[UIColor colorWithRed:0.47 green:0.78 blue:0.96 alpha:0.5] set];
                        break;
                    case ALGTileColorDarkBlue:
                        [[UIColor colorWithRed:0.00 green:0.64 blue:1.00 alpha:0.5] set];
                        break;
                    case ALGTileColorRed:
                        [[UIColor colorWithRed:0.97 green:0.60 blue:0.55 alpha:0.5] set];
                        break;
                    case ALGTileColorDarkRed:
                        [[UIColor colorWithRed:1.00 green:0.26 blue:0.18 alpha:0.5] set];
                        break;
                    case ALGTileColorWhite:
                        [[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.5f] set];
                        break;
                    }
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextFillEllipseInRect(ctx, tileRect);
            }
            if (YES == [_selectedTiles[ii * 5 + jj] boolValue]) {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextSetLineWidth(ctx, 4.f);
                CGContextSetRGBStrokeColor(ctx, 1.f, 0.f, 0.f, 0.5);
                CGContextStrokeEllipseInRect(ctx, insetRect);
            }
        }
    }
}

#pragma mark - Properties

- (void)setScreenshotReader:(ALGScreenshotReader *)screenshotReader {
    _screenshotReader = screenshotReader;
    [self setNeedsDisplay];
}

- (void)setHitWord:(NSString *)hitWord {
    _hitWord = [hitWord uppercaseString];
    [self setNeedsDisplay];
}

- (void)setBoardImage:(UIImage *)boardImage {
    _boardImage = boardImage;
    [self setNeedsDisplay];
}

- (CGSize)tileSize {
    return CGSizeMake(self.bounds.size.width / 5.f, self.bounds.size.height / 5.f);
}

#pragma mark - Gesture Recognizers

- (void)tapped:(UITapGestureRecognizer *)recognizer {
    if (nil == _screenshotReader) {
        return;
    }
    CGPoint pt = [recognizer locationInView:self];
    // what tile are they in?
    CGSize s = self.tileSize;
    int row = -1;
    int col = -1;
    for (int ii = 0; ii < 5; ++ii) {
        for (int jj = 0; jj < 5; ++jj) {
            CGRect tileRect = CGRectMake(jj * s.width, ii * s.height, s.width, s.height);
            if (CGRectContainsPoint(tileRect, pt)) {
                row = ii;
                col = jj;
                break;
            }
        }
    }
    NSAssert(row != -1 && col != -1, @"Tap wasn't in a tile");
    _selectedTiles[col + row * 5] = ([_selectedTiles[col + row * 5] boolValue] == YES) ? @(NO) : @(YES);
    NSString *boardLetters = [_screenshotReader stringForTiles];
    int ii = 0;
    NSMutableString *selectedLetters = [NSMutableString stringWithCapacity:25];
    for (NSNumber *n in _selectedTiles) {
        if (YES == [n boolValue]) {
            [selectedLetters appendString:[boardLetters substringWithRange:NSMakeRange(ii, 1)]];
        }
        ++ii;
    }
    _selectedString = selectedLetters;
    [self.delegate boardViewDidChangeTileSelection:self];
    [self setNeedsDisplay];
}

@end
