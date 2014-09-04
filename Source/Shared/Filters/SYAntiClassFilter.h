//
//  SYAntiClassFilter.h
//  Shelley
//
//  Created by Oleksiy Radyvanyuk on 04/09/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "SYClassFilter.h"

@interface SYAntiClassFilter : SYClassFilter

+ (NSArray *)filteredDescendantsOf:(ShelleyView *)view exceptClass:(Class)aClass;

@end
