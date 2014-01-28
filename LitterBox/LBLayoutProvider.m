//
//  LBLayoutProvider.m
//  LitterBox
//
//  Created by Cody Singleton on 9/23/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBLayoutProvider.h"

@implementation LBLayoutProvider

+ (CGRect)siteImageViewFrameForBounds:(CGRect)bounds imageSize:(CGSize)imageSize hidden:(BOOL)hidden
{
    CGRect imageViewFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        imageViewFrame.size.height = imageSize.height;
        imageViewFrame.size.width = imageSize.width;
        imageViewFrame.origin.y = hidden ? -(imageSize.height + kLBSiteImageViewYOffset_Pad) : kLBSiteImageViewYOffset_Pad;
        imageViewFrame.origin.x = kLBSiteImageViewXOffset_Pad;
    }
    else {
        imageViewFrame.size.height = imageSize.height;
        imageViewFrame.size.width = imageSize.width;
        imageViewFrame.origin.y = hidden ? -(imageSize.height + kLBSiteImageViewYOffset_Phone) : kLBSiteImageViewYOffset_Phone;
        imageViewFrame.origin.x = kLBSiteImageViewXOffset_Phone;
    }
    return imageViewFrame;
}

+ (UIFont *)siteNameLabelFont
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:64.0f];
    }
    else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f];
    }
}

+ (CGRect)siteNameLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden
{
    CGRect labelFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.size.height = kLBSiteNameLabelHeight_Pad;
        labelFrame.origin.y = kLBSiteNameLabelYOffset_Pad;
        labelFrame.size.width = labelFrame.size.width - kLBSiteNameLabelXOffset_Pad;
        labelFrame.origin.x = hidden ? bounds.size.width : kLBSiteNameLabelXOffset_Pad;
    }
    else {
        labelFrame.size.height = kLBSiteNameLabelHeight_Phone;
        labelFrame.origin.y = kLBSiteNameLabelYOffset_Phone;
        labelFrame.size.width = labelFrame.size.width - kLBSiteNameLabelXOffset_Phone;
        labelFrame.origin.x = hidden ? bounds.size.width : kLBSiteNameLabelXOffset_Phone;
    }
    return labelFrame;
}

+ (UIFont *)siteStateLabelFont
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0f];
    }
    else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    }
}

+ (CGRect)siteStateLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden
{
    CGRect labelFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.size.height = kLBSiteStateLabelHeight_Pad;
        labelFrame.origin.y = kLBSiteStateLabelYOffset_Pad;
        labelFrame.size.width = labelFrame.size.width - kLBSiteStateLabelXOffset_Pad;
        labelFrame.origin.x = hidden ? bounds.size.width : kLBSiteStateLabelXOffset_Pad;
    }
    else {
        labelFrame.size.height = kLBSiteStateLabelHeight_Phone;
        labelFrame.origin.y = kLBSiteStateLabelYOffset_Phone;
        labelFrame.size.width = labelFrame.size.width - kLBSiteStateLabelXOffset_Phone;
        labelFrame.origin.x = hidden ? bounds.size.width : kLBSiteStateLabelXOffset_Phone;
    }
    return labelFrame;
}

+ (UIFont *)valuesLabelFont
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:(arc4random() % 72 + 32)];
    }
    else {
        return [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:(arc4random() % 36 + 16)];
    }
}

+ (CGRect)valuesLabelFrameForBounds:(CGRect)bounds
{
    CGRect labelFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.size.height = kLBValuesLabelHeight_Pad;
        labelFrame.origin.y = kLBValuesLabelYOffset_Pad;
        labelFrame.size.width = kLBValuesLabelWidth_Pad;
        labelFrame.origin.x = (bounds.size.width - kLBValuesLabelWidth_Pad) / 2.0;
    }
    else {
        labelFrame.size.height = kLBValuesLabelHeight_Phone;
        labelFrame.origin.y = kLBValuesLabelYOffset_Phone;
        labelFrame.size.width = kLBValuesLabelWidth_Phone;
        labelFrame.origin.x = (bounds.size.width - kLBValuesLabelWidth_Phone) / 2.0;
    }
    return labelFrame;
}

+ (CGRect)keySegmenetedControlFrameForBounds:(CGRect)bounds
{
    CGRect labelFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.size.height = kLBKeySegmnetedControlHeight_Pad;
        labelFrame.origin.y = kLBKeySegmnetedControlYOffset_Pad;
        labelFrame.size.width = kLBKeySegmnetedControlWidth_Pad;
        labelFrame.origin.x = kLBKeySegmnetedControlXOffset_Pad;
    }
    else {
        labelFrame.size.height = kLBKeySegmnetedControlHeight_Phone;
        labelFrame.origin.y = kLBKeySegmnetedControlYOffset_Phone;
        labelFrame.size.width = kLBKeySegmnetedControlWidth_Phone;
        labelFrame.origin.x = kLBKeySegmnetedControlXOffset_Phone;
    }
    return labelFrame;
}

// site image view constants
const CGFloat kLBSiteImageViewXOffset_Phone = 10.0f;
const CGFloat kLBSiteImageViewYOffset_Phone = 150.0f;

const CGFloat kLBSiteImageViewXOffset_Pad = 134.0f;
const CGFloat kLBSiteImageViewYOffset_Pad = 180.0f;

// site state label constants
const CGFloat kLBSiteStateLabelHeight_Phone = 20.0f;
const CGFloat kLBSiteStateLabelXOffset_Phone = 70.0f;
const CGFloat kLBSiteStateLabelYOffset_Phone = 150.0f;

const CGFloat kLBSiteStateLabelHeight_Pad = 40.0f;
const CGFloat kLBSiteStateLabelXOffset_Pad = 140.0f;
const CGFloat kLBSiteStateLabelYOffset_Pad = 145.0f;

// site name label constants
const CGFloat kLBSiteNameLabelHeight_Phone = 50.0f;
const CGFloat kLBSiteNameLabelXOffset_Phone = 70.0f;
const CGFloat kLBSiteNameLabelYOffset_Phone = 160.0f;

const CGFloat kLBSiteNameLabelHeight_Pad = 100.0f;
const CGFloat kLBSiteNameLabelXOffset_Pad = 140.0f;
const CGFloat kLBSiteNameLabelYOffset_Pad = 185.0f;

// values label constants
const CGFloat kLBValuesLabelWidth_Phone = 300.0f;
const CGFloat kLBValuesLabelHeight_Phone = 200.0f;
const CGFloat kLBValuesLabelYOffset_Phone = 235.0f;

const CGFloat kLBValuesLabelWidth_Pad = 748.0f;
const CGFloat kLBValuesLabelHeight_Pad = 345.0f;
const CGFloat kLBValuesLabelYOffset_Pad = 490.0f;

// key label constants
const CGFloat kLBKeySegmnetedControlWidth_Phone = 180.0f;
const CGFloat kLBKeySegmnetedControlHeight_Phone = 24.0f;
const CGFloat kLBKeySegmnetedControlYOffset_Phone = 210.0f;
const CGFloat kLBKeySegmnetedControlXOffset_Phone = 10.0f;

const CGFloat kLBKeySegmnetedControlWidth_Pad = 748.0f;
const CGFloat kLBKeySegmnetedControlHeight_Pad = 60.0f;
const CGFloat kLBKeySegmnetedControlYOffset_Pad = 430.0f;
const CGFloat kLBKeySegmnetedControlXOffset_Pad = 10.0f;

@end
