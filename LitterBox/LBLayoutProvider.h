//
//  LBLayoutProvider.h
//  LitterBox
//
//  Created by Cody Singleton on 9/23/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBLayoutProvider : NSObject

+ (CGRect)siteImageViewFrameForBounds:(CGRect)bounds imageSize:(CGSize)imageSize hidden:(BOOL)hidden;

+ (CGRect)siteNameLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden;

+ (UIFont *)siteNameLabelFont;

+ (CGRect)siteStateLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden;

+ (UIFont *)siteStateLabelFont;

+ (CGRect)valuesLabelFrameForBounds:(CGRect)bounds;

+ (UIFont *)valuesLabelFont;

+ (CGRect)keySegmenetedControlFrameForBounds:(CGRect)bounds;

@end
