//
//  ALGOverlayView.h
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALGScreenshotReader;

@interface ALGOverlayView : UIView

@property (nonatomic, strong) ALGScreenshotReader *screenshotReader;

@end
