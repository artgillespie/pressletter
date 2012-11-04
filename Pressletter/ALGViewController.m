//
//  ALGViewController.m
//  Pressletter
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "ALGViewController.h"
#import "ALGScreenshotReader.h"
#import "ALGOverlayView.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALGViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ALGOverlayView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *hitLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *hitCountLabel;
@property (weak, nonatomic) UIImageView *defaultView; // fade on launch
@end

// can we spell a with non-repeating instances of the characters in b?
bool ALGCanSpell(NSString *a, NSString *b) {
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

@implementation ALGViewController {
    __strong NSArray *_wordDictionary;
    __strong NSArray *_hitWords;
    NSInteger _hitIndex;
    // for iPad
    __strong UIPopoverController *_imagePickerPopover;
}

- (void)setupDefaultView {
    CGSize selfSize = [UIScreen mainScreen].bounds.size;
    UIImageView *defaultView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, selfSize.width, selfSize.height)];
    defaultView.contentMode = UIViewContentModeTop;
    // which image should we use?
    if (1024.f == selfSize.height && 768.f == selfSize.width) {
        defaultView.image = [UIImage imageNamed:@"Default"];
    } else if (480.f == selfSize.height) {
        defaultView.image = [UIImage imageNamed:@"Default"];
    } else if (568.f == selfSize.height) {
        defaultView.image = [UIImage imageNamed:@"Default-568h"];
    }
    [self.view addSubview:defaultView];
    self.defaultView = defaultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDictionary];
    UIImage *image = [[UIImage imageNamed:@"UIAlertSheetBlackCancelButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.f, 13.f, 0.f, 13.f)];
    [self.chooseButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.lastButton setBackgroundImage:image forState:UIControlStateNormal];
    UIImage *helpImage = [UIImage imageNamed:@"HelpPlaceholder"];
    self.imageView.image = helpImage;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [self.hitLabel addGestureRecognizer:tapRecognizer];
    self.hitLabel.userInteractionEnabled = YES;
    self.hitLabel.text = @"";
    self.hitCountLabel.text = @"";
    [self setupDefaultView];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readImage:(UIImage *)image {
    NSParameterAssert([NSThread isMainThread]);
    self.overlayView.screenshotReader = nil;
    self.hitLabel.text = @"";
    self.hitCountLabel.text = @"";
    [self.activityIndicator startAnimating];
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    self.imageView.image = reader.croppedImage;
    __weak ALGViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (NO == [reader read]) {
            NSLog(@"error reading screenshot!");
            [self.activityIndicator stopAnimating];
            return;
        } else {
        }
        NSString *compareString = [[reader stringForTiles] lowercaseString];
        NSMutableArray *hits = [NSMutableArray arrayWithCapacity:1024];
        NSInteger hitCount = 0;
        for (NSString *word in _wordDictionary) {
            if (true == ALGCanSpell(word, compareString)) {
                [hits addObject:word];
                hitCount++;
                if (hitCount > 40)
                    break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.overlayView.screenshotReader = reader;
            _hitWords = [NSArray arrayWithArray:hits];
            _hitIndex = 0;
            [weakSelf updateHitLabel];
            [self.activityIndicator stopAnimating];
        });
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

- (void)loadDictionary {
    NSString *dictionaryPath = [[NSBundle mainBundle] pathForResource:@"dict_long_to_short.txt" ofType:nil];
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:dictionaryPath encoding:NSUTF8StringEncoding error:&error];
    if (nil == fileContents) {
        NSAssert(NO, @"Couldn't load fileContents: %@", error);
    }
    _wordDictionary = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (void)updateHitLabel {
    if (nil == _hitWords) {
        return;
    }
    self.overlayView.hitWord = _hitWords[_hitIndex];
    self.hitLabel.text = [_hitWords[_hitIndex] uppercaseString];
    self.hitCountLabel.text = [NSString stringWithFormat:@"%d/%d", _hitIndex + 1, [_hitWords count]];
}

- (void)labelTapped:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint loc = [gestureRecognizer locationInView:self.hitLabel];
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
    }
    [self updateHitLabel];
}

- (void)viewDidUnload {
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}
@end
