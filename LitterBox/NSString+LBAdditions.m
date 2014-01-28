//
//  NSString+LBAdditions.m
//  LitterBox
//
//  Created by Cody Singleton on 11/18/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "NSString+LBAdditions.h"

@implementation NSString (LBAdditions)

- (BOOL)isGuid
{
    NSString *regexString = @"[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}";
    NSRange range = [self rangeOfString:regexString options:NSRegularExpressionSearch];
    return (range.location == 0 && range.length == self.length);
}

@end
