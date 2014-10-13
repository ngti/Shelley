//
//  UIView+ShelleyExtensions.m
//  Shelley
//
//  Created by Pete Hodgson on 7/22/11.
//  Copyright 2011 ThoughtWorks. All rights reserved.
//

#import "LoadableCategory.h"

#import <QuartzCore/QuartzCore.h>

MAKE_CATEGORIES_LOADABLE(UIView_ShelleyExtensions)

BOOL substringMatch(NSString *actualString, NSString *expectedSubstring){
    // for some reason Apple like to re-encode some spaces into non-breaking spaces, for example in the 
    // UITextFieldLabel's accessibilityLabel. We work around that here by subbing the nbsp for a regular space
    NSString *nonBreakingSpace = [NSString stringWithUTF8String:"\u00a0"];
    actualString = [actualString stringByReplacingOccurrencesOfString:nonBreakingSpace withString:@" "];
    
    return actualString && ([actualString rangeOfString:expectedSubstring].location != NSNotFound);    
}

@implementation UIView (ShelleyExtensions)

- (BOOL) marked:(NSString *)targetLabel{
    return substringMatch([self accessibilityLabel], targetLabel);
}

- (BOOL) markedExactly:(NSString *)targetLabel{
    return [[self accessibilityLabel] isEqualToString:targetLabel];
}

- (BOOL) FEX_isAnimating {
    // special case: on iPad this class has animated flag set constantly when onscreen keyboard is displayed
    if ([self isKindOfClass:NSClassFromString(@"UIKeyboardSliceTransitionView")])
        return NO;

    // special case: if this is an UIImageView that is animating and if it is animating infinitely,
    // ignore it since the function "wait_for_nothing_to_be_animating" will enter the infinite loop
    if ([self isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageView = (UIImageView *)self;
        if ([imageView isAnimating])
        {
            return 0 != [imageView animationRepeatCount];
        }
    }
    else
    {
        // special case: since we no longer access "isAnimating" method from target class directly,
        // forward it to particular classes that implement this method
        if ([self respondsToSelector:@selector(isAnimating)])
        {
            return [self performSelector:@selector(isAnimating) withObject:nil];
        }
    }

    if ([self respondsToSelector:@selector(motionEffects)]) {
        return (self.layer.animationKeys.count > [[self performSelector: @selector(motionEffects)] count]);
    }
    else {
        return (self.layer.animationKeys.count > 0);
    }
}

- (BOOL) isNotAnimating {
    return ![self FEX_isAnimating];
}

- (UIColor *)colorOfCenterPoint
{
    // find width and height of the image to be rendered
    NSUInteger width = self.layer.bounds.size.width;
    NSUInteger height = self.layer.bounds.size.height;

    // deterimne coordinates of the center point of the image
    CGPoint center = CGPointMake(width / 2, height / 2);

    // setup color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // allocate memory that the image data will be put into
    unsigned char *rawData = malloc(height * width * 4);
    
    // create a CGBitmapContext to draw an image into
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    // draw the image which will populate rawData
    [self.layer renderInContext:context];
    CGContextRelease(context);

    long pixelIndex = (bytesPerRow * center.y) + center.x * bytesPerPixel;

    // extract components in RBGA format (don't ask me why!)
    CGFloat max = (CGFloat)0xff;

    CGFloat red = (CGFloat)rawData[pixelIndex] / max;
    CGFloat blue = (CGFloat)rawData[pixelIndex + 1] / max;
    CGFloat green = (CGFloat)rawData[pixelIndex + 2] / max;
    CGFloat alpha = (CGFloat)rawData[pixelIndex + 3] / max;

    free(rawData);

    // create and return color object
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

@implementation UILabel (ShelleyExtensions)
- (BOOL) text:(NSString *)expectedText{
    return substringMatch([self text], expectedText);
}
@end

@implementation UITextField (ShelleyExtensions)

- (BOOL) placeholder:(NSString *)expectedPlaceholder{
    return substringMatch([self placeholder], expectedPlaceholder);
}

- (BOOL) text:(NSString *)expectedText{
    return substringMatch([self text], expectedText);
}

@end

@implementation UIScrollView (ShelleyExtensions)
-(void) scrollDown:(int)offset {
	[self setContentOffset:CGPointMake(0,offset) animated:NO];
}

-(void) scrollToBottom {
	CGPoint bottomOffset = CGPointMake(0, [self contentSize].height);
	[self setContentOffset: bottomOffset animated: YES];
}

@end

@implementation UITableView (ShelleyExtensions)

-(NSArray *)rowIndexPathList {
	NSMutableArray *rowIndexPathList = [NSMutableArray array];
	int numberOfSections = [self numberOfSections];
	for(int i=0; i< numberOfSections; i++) {
		int numberOfRowsInSection = [self numberOfRowsInSection:i];
		for(int j=0; j< numberOfRowsInSection; j++) {
			[rowIndexPathList addObject:[NSIndexPath indexPathForRow:j inSection:i]];
		}
	}
	return rowIndexPathList;
}

-(void) scrollDownRows:(int)numberOfRows {
	NSArray *indexPathsForVisibleRows = [self indexPathsForVisibleRows];
	NSArray *rowIndexPathList = [self rowIndexPathList];
	
	NSIndexPath *indexPathForLastVisibleRow = [indexPathsForVisibleRows lastObject];
	
	int indexOfLastVisibleRow = [rowIndexPathList indexOfObject:indexPathForLastVisibleRow];
	int scrollToIndex = indexOfLastVisibleRow + numberOfRows;
	if (scrollToIndex >= rowIndexPathList.count) {
		scrollToIndex = rowIndexPathList.count - 1;
	}
	NSIndexPath *scrollToIndexPath = [rowIndexPathList objectAtIndex:scrollToIndex];
	[self scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void) scrollToBottom {
    int numberOfSections = [self numberOfSections];
    int numberOfRowsInSection = [self numberOfRowsInSection:numberOfSections-1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRowsInSection-1 inSection:numberOfSections-1];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end

