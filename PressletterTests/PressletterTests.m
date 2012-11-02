//
//  PressletterTests.m
//  PressletterTests
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "PressletterTests.h"
#import "ALGScreenshotReader.h"
#import "ALGImageUtilities.h"

@implementation PressletterTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testImageLoad {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IMG_1384" ofType:@"PNG"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
}

- (void)testLoadingFontInTestBundle {
    // wasn't even sure this was possible
    for (NSString *familyName in [UIFont familyNames]) {
        NSLog(@"familyName: %@", familyName);
    }
    UIFont *font = [UIFont fontWithName:@"MuseoSansRounded-700" size:12.f];
    STAssertNotNil(font, @"Couldn't load font");
}

- (void)testAlphaSheet {
    UIImage *alphaSheet = [ALGImageUtilities alphabetSheet:YES];
    NSData *pngData = UIImagePNGRepresentation(alphaSheet);
    NSError *error = nil;
    if(NO == [pngData writeToFile:@"/Users/artgillespie/Desktop/alphaSheet.png" options:NSDataWritingAtomic error:&error]) {
        STFail(@"Couldn't write alphaSheet to file: %@", error);
    }
}

- (void)testReaderWith1384 {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IMG_1386" ofType:@"PNG"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
        @[@"L", @"P", @"G", @"O", @"C"],
        @[@"C", @"Z", @"I", @"R", @"J"],
        @[@"K", @"C", @"C", @"M", @"X"],
        @[@"L", @"U", @"Z", @"S", @"K"],
        @[@"M", @"F", @"M", @"X", @"K"],
    ];
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testReaderWithiPhone5_1 {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone_5_1" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"P", @"R", @"I", @"Z", @"S"],
    @[@"U", @"T", @"V", @"Z", @"R"],
    @[@"A", @"T", @"S", @"R", @"S"],
    @[@"E", @"R", @"D", @"N", @"F"],
    @[@"G", @"O", @"W", @"C", @"S"],
    ];
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testReaderWithiPhone5_2 {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone_5_2" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"P", @"N", @"S", @"E", @"N"],
    @[@"A", @"H", @"M", @"U", @"O"],
    @[@"R", @"T", @"F", @"H", @"I"],
    @[@"G", @"C", @"S", @"C", @"W"],
    @[@"P", @"D", @"O", @"E", @"A"],
    ];
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

@end
