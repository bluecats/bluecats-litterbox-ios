//
//  NSDate+LBAdditions.m
//  LitterBox
//
//  Created by Cody Singleton on 11/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "NSDate+LBAdditions.h"

@implementation NSDate (LBAdditions)

- (NSString *)stringWithMediumStyle
{
    if (!self) return nil;
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    
    return [dateFormatter stringFromDate:self];
}

@end
