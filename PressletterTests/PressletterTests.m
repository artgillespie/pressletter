//
//  PressletterTests.m
//  PressletterTests
//
//  Created by Art Gillespie on 11/2/12.
//  Copyright (c) 2012 Art Gillespie. All rights reserved.
//

#import "PressletterTests.h"
#import "ALGScreenshotReader.h"

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

- (void)testReaderWith1384 {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IMG_1384" ofType:@"PNG"];
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
    for (int ii = 0; ii < 5; ++ii) {
        for (int jj = 0; jj < 5; ++jj) {
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertEquals(expected[ii][jj], tile.letter, @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

@end
