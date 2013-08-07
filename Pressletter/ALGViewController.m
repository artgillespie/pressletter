//
//  ALGViewController.m
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

#import "ALGViewController.h"
#import "ALGScreenshotReader.h"
#import "ALGBoardView.h"

#import <AssetsLibrary/AssetsLibrary.h>

// can we spell a with non-repeating instances of the characters in b?
bool ALGCanSpell(NSString *a, NSString *b) {
    /*
     * This is a pretty straightforward algorithm. We represent the English
     * alphabet as a 26-item array and count the number of times a letter occurs
     * in both the a and b string. Then, if any letter in a's array has a higher
     * count than b, we know we can't spell a with the letters in b.
     */
    const char *aStr = [a cStringUsingEncoding:NSUTF8StringEncoding];
    const char *bStr = [b cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char a_t[26];
    memset(a_t, 0, 26);
    unsigned char b_t[26];
    memset(b_t, 0, 26);
    for (int ii = 0; ii < strlen(aStr); ++ii) {
        unsigned char c = aStr[ii] - 'a';
        a_t[c]++;
    }
    for (int ii = 0; ii < strlen(bStr); ++ii) {
        unsigned char c = bStr[ii] - 'a';
        b_t[c]++;
    }
    for (int ii = 0; ii < 26; ++ii) {
        if (a_t[ii] > b_t[ii]) {
            return false;
        }
    }
    return true;
}

// given the characters in weightedChars, which of a or b is more
// valuable?
NSComparisonResult ALGWeightedCompare(NSString *weightedChars, NSString *a, NSString *b) {
    const char *aStr = [a cStringUsingEncoding:NSUTF8StringEncoding];
    const char *bStr = [b cStringUsingEncoding:NSUTF8StringEncoding];
    const char *wStr = [weightedChars cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char a_t[26];
    memset(a_t, 0, 26);
    unsigned char b_t[26];
    memset(b_t, 0, 26);
    unsigned char w_t[26];
    memset(w_t, 0, 26);
    for (int ii = 0; ii < strlen(aStr); ++ii) {
        unsigned char c = aStr[ii] - 'a';
        a_t[c]++;
    }
    for (int ii = 0; ii < strlen(bStr); ++ii) {
        unsigned char c = bStr[ii] - 'a';
        b_t[c]++;
    }
    for (int ii = 0; ii < strlen(wStr); ++ii) {
        unsigned char c = wStr[ii] - 'a';
        w_t[c]++;
    }
    int aWeight = 0;
    int bWeight = 0;
    for (int ii = 0; ii < 26; ++ii) {
        aWeight += MIN(a_t[ii], w_t[ii]);
        bWeight += MIN(b_t[ii], w_t[ii]);
    }
    if (aWeight > bWeight) {
        return NSOrderedAscending;
    } else if (aWeight < bWeight) {
        return NSOrderedDescending;
    } else if ([a length] > [b length]) {
        return NSOrderedAscending;
    } else if ([a length] < [b length]) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

NSArray *ALGLoadWordList(NSString *path) {
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (nil == fileContents) {
        NSCAssert(NO, @"Couldn't load fileContents: %@", error);
    }
    return [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

/*
 * Get the cache directory, creating it if necessary.
 */
NSString *ALGGetCachePath() {
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *cachePath = [libraryPath stringByAppendingPathComponent:@"com.tapsquare.pressletter/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    return cachePath;
}

/**
 * Return the word list for the given board string if it's stored on disk.
 */
NSArray *ALGGetCachedHits(NSString *boardString) {
    NSString *cachePath = ALGGetCachePath();
    NSString *boardPath = [cachePath stringByAppendingPathComponent:[boardString stringByAppendingPathExtension:@"txt"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:boardPath]) {
        return [NSArray arrayWithContentsOfFile:boardPath];
    }
    return nil;
}

BOOL ALGCacheHits(NSString *boardString, NSArray *hits) {
    NSString *cachePath = ALGGetCachePath();
    NSString *boardPath = [cachePath stringByAppendingPathComponent:[boardString stringByAppendingPathExtension:@"txt"]];
    return [hits writeToFile:boardPath atomically:YES];
}

@interface ALGViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, ALGBoardViewDelegate>
@property (weak, nonatomic) IBOutlet ALGBoardView *boardView;
@property (weak, nonatomic) IBOutlet UILabel *hitLabel;
@property (strong, nonatomic) UILabel *hitLabel2;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *hitCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImageView;
@property (weak, nonatomic) UIImageView *defaultView; // fade on launch
@end

@implementation ALGViewController {
    __strong NSArray *_wordDictionary;
    __strong NSArray *_hitWords;
    NSInteger _hitIndex;
    // for iPad - We have to present the image picker in a popover
    __strong UIPopoverController *_imagePickerPopover;
}

/*
 * The default image view provides us with a nice animation from Default.png
 * to our UI.
 */
- (void)setupDefaultView {
    CGSize selfSize = [UIScreen mainScreen].bounds.size;
    selfSize.height -= 20.f;
    UIImageView *defaultView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, selfSize.width, selfSize.height)];
    defaultView.contentMode = UIViewContentModeBottom;
    // which image should we use?
    if (1004.f == selfSize.height && 768.f == selfSize.width) {
        defaultView.image = [UIImage imageNamed:@"Default"];
    } else if (460.f == selfSize.height) {
        defaultView.image = [UIImage imageNamed:@"Default"];
    } else if (548.f == selfSize.height) {
        defaultView.image = [UIImage imageNamed:@"Default-568h"];
    }
    [self.view addSubview:defaultView];
    self.defaultView = defaultView;
}

- (void)setupHitLabel2 {
    // setup the 'back' hit label
    // We have two UILabel instances to make the animation left and right work.
    UILabel *hitLabel2 = [[UILabel alloc] initWithFrame:self.hitLabel.frame];
    hitLabel2.userInteractionEnabled = YES;
    hitLabel2.contentMode = self.hitLabel.contentMode;
    hitLabel2.textAlignment = self.hitLabel.textAlignment;
    hitLabel2.font = self.hitLabel.font;
    hitLabel2.textColor = self.hitLabel.textColor;
    hitLabel2.clearsContextBeforeDrawing = YES;
    hitLabel2.backgroundColor = self.hitLabel.backgroundColor;
    hitLabel2.opaque = self.hitLabel.opaque;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [hitLabel2 addGestureRecognizer:tapRecognizer];
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [hitLabel2 addGestureRecognizer:doubleTapRecognizer];
    hitLabel2.hidden = YES;
    [self.view insertSubview:hitLabel2 belowSubview:self.leftArrowImageView];
    self.hitLabel2 = hitLabel2;
}

- (void)setupBoard {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [[UIImage imageNamed:@"UIAlertSheetBlackCancelButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.f, 13.f, 0.f, 13.f)];
    [self.chooseButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.lastButton setBackgroundImage:image forState:UIControlStateNormal];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [self.hitLabel addGestureRecognizer:tapRecognizer];
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.hitLabel addGestureRecognizer:doubleTapRecognizer];
    self.hitLabel.userInteractionEnabled = YES;
    self.hitLabel.text = @"";
    self.hitCountLabel.text = @"";
    self.leftArrowImageView.hidden = YES;
    self.rightArrowImageView.hidden = YES;
    [self setupDefaultView];
    [self setupHitLabel2];
    [self setupBoard];
    self.boardView.boardImage = [UIImage imageNamed:@"HelpPlaceholder"];
    self.boardView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    if (nil == self.defaultView)
        return;
    [UIView animateWithDuration:.5 animations:^{
        CGRect f = self.defaultView.frame;
        f.origin.y -= f.size.height;
        self.defaultView.frame = f;
        self.defaultView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.defaultView removeFromSuperview];
        self.defaultView = nil;
    }];
    [self.boardView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readImage:(UIImage *)image {
    NSParameterAssert([NSThread isMainThread]);
    self.boardView.screenshotReader = nil;
    self.hitLabel.text = @"";
    self.hitCountLabel.text = @"";
    self.leftArrowImageView.hidden = YES;
    self.rightArrowImageView.hidden = YES;
    [self.activityIndicator startAnimating];
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    self.boardView.boardImage = reader.croppedImage;
    __weak ALGViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (NO == [reader read]) {
            NSLog(@"error reading screenshot!");
            [self.activityIndicator stopAnimating];
            return;
        } else {
        }
        NSString *compareString = [[reader stringForTiles] lowercaseString];
        // see if we have a cached word list for this board
        NSArray *wordList = ALGGetCachedHits(compareString);
        if (nil != wordList && 0 != [wordList count]) {
            // if we have a cached word list, just load it
            dispatch_async(dispatch_get_main_queue(), ^{
                self.boardView.screenshotReader = reader;
                _hitWords = [NSArray arrayWithArray:wordList];
                _hitIndex = 0;
                [weakSelf updateHitLabel];
                self.leftArrowImageView.hidden = NO;
                self.rightArrowImageView.hidden = NO;
                [self.activityIndicator stopAnimating];
            });
            return;
        }

        if (nil == _wordDictionary) {
            // if the word dictionary isn't loaded, grab it
            NSString *dictionaryPath = [[NSBundle mainBundle] pathForResource:@"dict_long_to_short.txt" ofType:nil];
            _wordDictionary = ALGLoadWordList(dictionaryPath);
        }

        NSMutableArray *hits = [NSMutableArray arrayWithCapacity:1024];
        NSInteger hitCount = 0;
        for (NSString *word in _wordDictionary) {
            if ([word isEqualToString:@""]) {
                continue;
            }
            if (true == ALGCanSpell(word, compareString)) {
                [hits addObject:word];
                hitCount++;
                if (hitCount >= 1000) {
                    break;
                }
                if (1 == hitCount) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.boardView.screenshotReader = reader;
                        _hitWords = [NSArray arrayWithArray:hits];
                        _hitIndex = 0;
                        [weakSelf updateHitLabel];
                        self.leftArrowImageView.hidden = NO;
                        self.rightArrowImageView.hidden = NO;
                        [self.activityIndicator stopAnimating];
                    });
                } else if (0 == hitCount % 10) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.boardView.screenshotReader = reader;
                        _hitWords = [NSArray arrayWithArray:hits];
                        [weakSelf updateHitLabel];
                    });
                }
            }
        } // for (NSString *word in _wordDictionary)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.boardView.screenshotReader = reader;
            _hitWords = [NSArray arrayWithArray:hits];
            [weakSelf updateHitLabel];
        });
        if(NO == ALGCacheHits(compareString, [NSArray arrayWithArray:hits])) {
            NSLog(@"WTF COULDN'T SAVE CACHE...");
        }
    });
}

- (IBAction)chooseButton:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom) {
        _imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [_imagePickerPopover presentPopoverFromRect:self.chooseButton.bounds inView:self.chooseButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:^{}];
    }
}

- (IBAction)lastPhotoButton:(id)sender {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];

        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - 1]
                                options:0
                             usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {

                                 // The end of the enumeration is signaled by asset == nil.
                                 if (alAsset) {
                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                     UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                                     __weak ALGViewController *weakSelf = self;
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [weakSelf readImage:latestPhoto];
                                     });
                                 }
                             }];
    }
                         failureBlock: ^(NSError *error) {
                             // Typically you should handle an error more gracefully than this.
                             NSLog(@"No groups");
                         }];
}

#pragma mark - ALGBoardViewDelegate

- (void)boardViewDidChangeTileSelection:(ALGBoardView *)boardView {
    /*
     * Weighting:
     * w = number of letters from searchString that are in value, factoring for
     * repeats.
     */
    self.hitLabel.text = @"";
    self.hitCountLabel.text = @"";
    self.leftArrowImageView.hidden = YES;
    self.rightArrowImageView.hidden = YES;
    self.boardView.userInteractionEnabled = NO;
    [self.activityIndicator startAnimating];

    NSLog(@"filtering selectedLetters: %@", self.boardView.selectedString);
    NSString *compareString = [self.boardView.selectedString lowercaseString];
    __weak ALGViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *sorted = [_hitWords sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return ALGWeightedCompare(compareString, obj1, obj2);
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"filtered: %d", [sorted count]);
            _hitWords = sorted;
            _hitIndex = 0;
            [self.activityIndicator stopAnimating];
            self.leftArrowImageView.hidden = NO;
            self.rightArrowImageView.hidden = NO;
            [weakSelf updateHitLabel];
            self.boardView.userInteractionEnabled = YES;
        });
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom) {
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    [self readImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom) {
        [_imagePickerPopover dismissPopoverAnimated:YES];
        _imagePickerPopover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)updateHitLabel {
    if (nil == _hitWords) {
        return;
    }
    self.boardView.hitWord = _hitWords[_hitIndex];
    self.hitLabel.text = [_hitWords[_hitIndex] uppercaseString];
    self.hitCountLabel.text = [NSString stringWithFormat:@"%d/%d", _hitIndex + 1, [_hitWords count]];
}

- (void)labelTapped:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint loc = [gestureRecognizer locationInView:gestureRecognizer.view];
    int direction = 1;
    if (loc.x > self.view.bounds.size.width / 2.f) {
        _hitIndex++;
        if (_hitIndex >= [_hitWords count]) {
            _hitIndex = 0;
        }
    } else {
        if (0 == _hitIndex) {
            _hitIndex = [_hitWords count] - 1;
        } else {
            _hitIndex--;
        }
        direction = -1;
    }
    self.boardView.hitWord = _hitWords[_hitIndex];
    CGRect f = self.hitLabel.frame;
    f.origin.x = direction * self.view.bounds.size.width;
    self.hitLabel2.frame = f;
    self.hitLabel2.text = [_hitWords[_hitIndex] uppercaseString];
    self.hitLabel2.hidden = NO;
    [self.hitLabel2 setNeedsDisplay];
    self.hitLabel2.userInteractionEnabled = NO;
    self.hitLabel.userInteractionEnabled = NO;
    __weak ALGViewController *weakSelf = self;
    [UIView animateWithDuration:.25f animations:^{
        CGRect f = weakSelf.hitLabel2.frame;
        f.origin.x = 0;
        weakSelf.hitLabel2.frame = f;
        f = weakSelf.hitLabel.frame;
        f.origin.x = -1 * direction * weakSelf.view.frame.size.width;
        weakSelf.hitLabel.frame = f;
    } completion:^(BOOL finished) {
        UILabel *tmp = weakSelf.hitLabel2;
        weakSelf.hitLabel2 = weakSelf.hitLabel;
        weakSelf.hitLabel = tmp;
        weakSelf.hitLabel2.hidden = YES;
        weakSelf.hitLabel.userInteractionEnabled = YES;
        self.hitCountLabel.text = [NSString stringWithFormat:@"%d/%d", _hitIndex + 1, [_hitWords count]];
    }];
    // [self updateHitLabel];
}

- (void)labelDoubleTapped:(UITapGestureRecognizer *)gestureRecognizer {
    _hitIndex = 0;
    [self updateHitLabel];
}

- (void)viewDidUnload {
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}
@end
