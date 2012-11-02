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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDictionary];
    UIImage *image = [[UIImage imageNamed:@"UIAlertSheetBlackCancelButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.f, 13.f, 0.f, 13.f)];
    [self.chooseButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.lastButton setBackgroundImage:image forState:UIControlStateNormal];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [self.hitLabel addGestureRecognizer:tapRecognizer];
    self.hitLabel.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readImage:(UIImage *)image {
    NSParameterAssert([NSThread isMainThread]);
    self.imageView.image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if (NO == [reader read]) {
        NSLog(@"error reading screenshot!");
        return;
    } else {
    }
    self.overlayView.screenshotReader = reader;
    __weak ALGViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *compareString = [[reader stringForTiles] lowercaseString];
        NSMutableArray *hits = [NSMutableArray arrayWithCapacity:1024];
        NSInteger hitCount = 0;
        for (NSString *word in _wordDictionary) {
            if (true == ALGCanSpell(word, compareString)) {
                [hits addObject:word];
                hitCount++;
                if (hitCount > 20)
                    break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _hitWords = [NSArray arrayWithArray:hits];
            _hitIndex = 0;
            [weakSelf updateHitLabel];
        });
    });
}

- (IBAction)chooseButton:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:^{}];
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
    [self readImage:image];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
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
}

- (void)labelTapped:(UITapGestureRecognizer *)gestureRecognizer {
    _hitIndex++;
    if (_hitIndex >= [_hitWords count]) {
        _hitIndex = 0;
    }
    [self updateHitLabel];
}

@end
