//
//  PressletterTests.m
//  PressletterTests
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

#import "PressletterTests.h"
#import "ALGScreenshotReader.h"
#import "ALGImageUtilities.h"

@implementation PressletterTests

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testReaderWith1386 {
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
    @[@"K", @"S", @"O", @"G", @"C"],
    @[@"N", @"U", @"P", @"T", @"S"],
    @[@"D", @"O", @"N", @"U", @"N"],
    @[@"S", @"R", @"E", @"S", @"L"],
    @[@"A", @"O", @"T", @"N", @"W"],
    ];

    __unused ALGTileColor colors[] = {ALGTileColorDarkBlue, ALGTileColorBlue, ALGTileColorBlue, ALGTileColorRed, ALGTileColorBlue,
                             ALGTileColorBlue, ALGTileColorRed, ALGTileColorBlue, ALGTileColorBlue, ALGTileColorBlue,
                             ALGTileColorRed, ALGTileColorBlue, ALGTileColorBlue, ALGTileColorRed, ALGTileColorRed,
                             ALGTileColorDarkRed, ALGTileColorRed, ALGTileColorBlue, ALGTileColorRed, ALGTileColorDarkRed,
                             ALGTileColorRed, ALGTileColorBlue, ALGTileColorDarkBlue, ALGTileColorBlue, ALGTileColorRed};

    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
            // TODO: We've removed support for color detection.
            // STAssertTrue(colors[ii * 5 + jj] == tile.tileColor, @"Unexpected tile color: %d != %d", colors[ii * 5 + jj], tile.tileColor);
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

- (void)testReaderWithiPadPortraitRetina {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPadPortrait_Retina" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"G", @"N", @"N", @"V", @"B"],
    @[@"P", @"U", @"I", @"M", @"I"],
    @[@"M", @"B", @"S", @"A", @"V"],
    @[@"T", @"U", @"O", @"E", @"T"],
    @[@"O", @"Z", @"S", @"F", @"G"],
    ];
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testReaderWithiPadLandscapeRetina {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPadLandscape_Retina" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"G", @"N", @"N", @"V", @"B"],
    @[@"P", @"U", @"I", @"M", @"I"],
    @[@"M", @"B", @"S", @"A", @"V"],
    @[@"T", @"U", @"O", @"E", @"T"],
    @[@"O", @"Z", @"S", @"F", @"G"],
    ];
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testReaderWithiPadLandscape {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPadLandscape" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"I", @"F", @"D", @"Q", @"X"],
    @[@"M", @"A", @"D", @"R", @"A"],
    @[@"G", @"A", @"E", @"P", @"C"],
    @[@"R", @"O", @"A", @"V", @"G"],
    @[@"H", @"S", @"H", @"L", @"Y"],
    ];
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testReaderWithiPadPortrait {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPadPortrait" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"I", @"F", @"D", @"Q", @"X"],
    @[@"M", @"A", @"D", @"R", @"A"],
    @[@"G", @"A", @"E", @"P", @"C"],
    @[@"R", @"O", @"A", @"V", @"G"],
    @[@"H", @"S", @"H", @"L", @"Y"],
    ];
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testColorTheme_Pop {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone4_Pop" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"T", @"O", @"S", @"L", @"F"],
    @[@"N", @"D", @"H", @"T", @"L"],
    @[@"X", @"G", @"S", @"W", @"G"],
    @[@"R", @"P", @"R", @"A", @"K"],
    @[@"L", @"P", @"A", @"Z", @"K"],
    ];
    
    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }    
}

- (void)testColorTheme_Retro {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone4_Retro" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"T", @"O", @"S", @"L", @"F"],
    @[@"N", @"D", @"H", @"T", @"L"],
    @[@"X", @"G", @"S", @"W", @"G"],
    @[@"R", @"P", @"R", @"A", @"K"],
    @[@"L", @"P", @"A", @"Z", @"K"],
    ];

    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testColorTheme_Pink {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone4_Pink" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"T", @"O", @"S", @"L", @"F"],
    @[@"N", @"D", @"H", @"T", @"L"],
    @[@"X", @"G", @"S", @"W", @"G"],
    @[@"R", @"P", @"R", @"A", @"K"],
    @[@"L", @"P", @"A", @"Z", @"K"],
    ];

    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testColorTheme_Glow {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone4_Glow" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"T", @"O", @"S", @"L", @"F"],
    @[@"N", @"D", @"H", @"T", @"L"],
    @[@"X", @"G", @"S", @"W", @"G"],
    @[@"R", @"P", @"R", @"A", @"K"],
    @[@"L", @"P", @"A", @"Z", @"K"],
    ];

    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testColorTheme_Forest {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone4_Forest" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"T", @"O", @"S", @"L", @"F"],
    @[@"N", @"D", @"H", @"T", @"L"],
    @[@"X", @"G", @"S", @"W", @"G"],
    @[@"R", @"P", @"R", @"A", @"K"],
    @[@"L", @"P", @"A", @"Z", @"K"],
    ];

    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

- (void)testColorTheme_Dark {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone4_Dark" ofType:@"png"];
    STAssertNotNil(imagePath, @"Expected Image Path");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(image, @"Expected image");
    ALGScreenshotReader *reader = [[ALGScreenshotReader alloc] initWithImage:image];
    if(NO == [reader read]) {
        STFail(@"[reader read] returned NO");
        return;
    }
    NSArray *expected = @[
    @[@"T", @"O", @"S", @"L", @"F"],
    @[@"N", @"D", @"H", @"T", @"L"],
    @[@"X", @"G", @"S", @"W", @"G"],
    @[@"R", @"P", @"R", @"A", @"K"],
    @[@"L", @"P", @"A", @"Z", @"K"],
    ];

    for (int ii = 0; ii < 5; ++ii) { // row
        for (int jj = 0; jj < 5; ++jj) { // column
            ALGScreenshotReaderTile *tile = [reader tileAtRow:ii column:jj];
            STAssertTrue([expected[ii][jj] isEqualToString:tile.letter], @"Unexpected letter at %d, %d (%@ != %@)", ii, jj, expected[ii][jj], tile.letter);
        }
    }
}

@end
