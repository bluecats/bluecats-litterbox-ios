//
//  LBCategoriesViewController.h
//  LitterBox
//
//  Created by Cody Singleton on 11/14/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBCategoriesViewControllerDelegate;

@class BCSite;

@interface LBCategoriesViewController : UIViewController

@property (nonatomic, assign) NSObject<LBCategoriesViewControllerDelegate> *delegate;
@property (nonatomic, copy) BCSite *site;

@end


@protocol LBCategoriesViewControllerDelegate <NSObject>

@required

- (void)categoriesViewControllerDone:(LBCategoriesViewController *)viewController;

@end