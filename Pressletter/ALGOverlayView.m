//
//  ALGOverlayView.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGOverlayView.h"
#import "ALGScreenshotReader.h"

@implementation ALGOverlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (nil == _screenshotReader) {
        return;
    }
    BOOL colorDebug = NO;
    for (int ii = 0; ii < 5; ++ii) { // rows
        for (int jj = 0; jj < 5; ++jj) {
            CGRect tileRect = CGRectMake(jj * 64.f, ii * 64.f, 64.f, 64.f);
            ALGScreenshotReaderTile *tile = [_screenshotReader tileAtRow:ii column:jj];
            [[UIColor blackColor] set];
            [tile.letter drawInRect:tileRect withFont:[UIFont boldSystemFontOfSize:14.f]];
            if (YES == colorDebug) {
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
            if (_hitWord && NSNotFound != [_hitWord rangeOfString:tile.letter].location) {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextSetLineWidth(ctx, 4.f);
                CGContextSetRGBStrokeColor(ctx, 1.f, 0.f, 0.f, 0.5);
                CGContextStrokeEllipseInRect(ctx, tileRect);
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

@end
