//
//  LBLayoutProvider.h
//  LitterBox
//
//  Created by Cody Singleton on 9/23/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBLayoutProvider : NSObject

+ (CGRect)siteNameLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden;

+ (UIFont *)siteNameLabelFont;

+ (CGRect)siteGreetingLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden;

+ (UIFont *)siteGreetingLabelFont;

+ (CGRect)categoriesLabelFrameForBounds:(CGRect)bounds;

+ (UIFont *)categoryLabelFont;

@end
