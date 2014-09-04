//
//  SYAntiClassFilter.m
//  Shelley
//
//  Created by Oleksiy Radyvanyuk on 04/09/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "SYAntiClassFilter.h"

@implementation SYAntiClassFilter

+ (NSArray *)filteredDescendantsOf:(ShelleyView *)view exceptClass:(Class)aClass
{
    NSMutableArray *descendants = [NSMutableArray array];

#if TARGET_OS_IPHONE
    for (ShelleyView *subview in [view subviews])
    {
        if (![subview isKindOfClass:aClass])
        {
            [descendants addObject:subview];
            [descendants addObjectsFromArray:[self filteredDescendantsOf:subview exceptClass:aClass]];
        }
    }
#else
    if ([view respondsToSelector: @selector(FEX_children)])
    {
        for (id child in [view performSelector: @selector(FEX_children)])
        {
            if (![subview isKindOfClass:aClass])
            {
                [descendants addObject: child];
                [descendants addObjectsFromArray: [self filteredDescendantsOf:child exceptClass:aClass]];
            }
        }
    }
    
#endif
    return descendants;
}

- (NSArray *)applyToView:(ShelleyView *)view
{
    NSMutableArray *allViews = [NSMutableArray array];
    [allViews addObjectsFromArray:[[self class] filteredDescendantsOf:view exceptClass:self.target]];
    return allViews;
}

@end
