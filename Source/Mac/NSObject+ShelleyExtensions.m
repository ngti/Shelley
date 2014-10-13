//
//  NSObject+ShelleyExtensions.m
//  Shelley
//
//  Created by Buckley on 1/16/13.
//

#import "LoadableCategory.h"

#import <QuartzCore/QuartzCore.h>

@interface NSObject()

- (NSString*) FEX_accessibilityLabel;

@end

MAKE_CATEGORIES_LOADABLE(NSObject_ShelleyExtensions)

BOOL substringMatch(NSString *actualString, NSString *expectedSubstring){
    // for some reason Apple like to re-encode some spaces into non-breaking spaces, for example in the
    // UITextFieldLabel's accessibilityLabel. We work around that here by subbing the nbsp for a regular space
    NSString *nonBreakingSpace = [NSString stringWithUTF8String:"\u00a0"];
    actualString = [actualString stringByReplacingOccurrencesOfString:nonBreakingSpace withString:@" "];
    
    return actualString && ([actualString rangeOfString:expectedSubstring].location != NSNotFound);
}

@implementation NSObject (ShelleyExtensions)

- (BOOL) marked:(NSString *)targetLabel{
    BOOL returnValue = NO;
    
    if ([self respondsToSelector: @selector(FEX_accessibilityLabel)])
    {
        returnValue = substringMatch([self FEX_accessibilityLabel], targetLabel);
    }
    
    return returnValue;
}

- (BOOL) markedExactly:(NSString *)targetLabel{
    BOOL returnValue = NO;
    
    if ([self respondsToSelector: @selector(FEX_accessibilityLabel)])
    {
        returnValue = [[self FEX_accessibilityLabel] isEqualToString:targetLabel];
    }
    
    return returnValue;
}

@end

@implementation NSView(SkelleyExtensions)

- (BOOL) FEX_isAnimating {
    return (self.layer.animationKeys.count > 0);
}

- (BOOL) isNotAnimating {
    return (self.layer.animationKeys.count == 0);
}

@end

@implementation NSTextView (ShelleyExtensions)
- (BOOL) text:(NSString *)expectedText{
    return substringMatch([self string], expectedText);
}
@end

@implementation NSTextField (ShelleyExtensions)
- (BOOL) text:(NSString *)expectedText{
    return substringMatch([self stringValue], expectedText);
}

- (BOOL) placeholder:(NSString *)expectedPlaceholder{
    return [self text: expectedPlaceholder];
}
@end

@implementation NSScrollView (ShelleyExtensions)
-(void) scrollDown:(int)offset {
	[[self contentView] scrollToPoint: CGPointMake(0,offset)];
}

-(void) scrollToBottom {
	CGPoint bottomOffset = CGPointMake(0, [self contentSize].height);
	[[self contentView] scrollToPoint: bottomOffset];
}

@end

@implementation NSTableView (ShelleyExtensions)

-(void) scrollDownRows:(int)numberOfRows {
    NSRange visibleRows = [self rowsInRect: [self visibleRect]];
    
    [self scrollRowToVisible: visibleRows.location + visibleRows.length + numberOfRows];
}

-(void) scrollToBottom {
    [[self enclosingScrollView] scrollToBottom];
}

@end

