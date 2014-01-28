//
//  LBOptionPickerViewController.h
//  LitterBox
//
//  Created by Cody Singleton on 11/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBOptionPickerViewControllerDelegate;

@interface LBOptionPickerViewController : UITableViewController

@property (nonatomic, assign) NSObject<LBOptionPickerViewControllerDelegate> *delegate;
@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic, strong, readonly) NSMutableArray *indexPathsOfSelectedOptions;
@property (nonatomic, strong) NSObject *tag;
@property (nonatomic, copy) NSString *keyPathForTitleInHeader;

- (void)selectOptionAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectOptionsAtIndexPaths:(NSArray *)indexPaths;

- (NSArray *)selectedOptions;

@end


@protocol LBOptionPickerViewControllerDelegate <NSObject>

@optional

- (void)optionPickerViewControllerDone:(LBOptionPickerViewController *)viewController;

- (void)optionPickerViewController:(LBOptionPickerViewController *)viewController didChangeSelectedOptions:(NSArray *)selectedOptions;

@end
