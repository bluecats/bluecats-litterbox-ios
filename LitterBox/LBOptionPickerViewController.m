//
//  LBOptionPickerViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBOptionPickerViewController.h"

static NSString * const kLBOptionCellIdentifier = @"OptionCell";

@interface LBOptionPickerViewController ()

@end

@implementation LBOptionPickerViewController

@synthesize indexPathsOfSelectedOptions = _indexPathsOfSelectedOptions;

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {

        _indexPathsOfSelectedOptions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.delegate = nil;
    self.options = nil;
    _indexPathsOfSelectedOptions = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        
        if ([self.delegate respondsToSelector:@selector(optionPickerViewControllerDone:)]) {
            [self.delegate optionPickerViewControllerDone:self];
        }
    }
}

- (BOOL)optionAtIndexPathIsSelected:(NSIndexPath *)indexPath
{
    for (NSIndexPath *indexPathOfSelectedOption in _indexPathsOfSelectedOptions) {
        
        if ([indexPathOfSelectedOption isEqual:indexPath]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSObject *)keyForSection:(NSInteger)section
{
    return [[self.options allKeys] objectAtIndex:section];
}

- (NSArray *)optionsForSection:(NSInteger)section
{
    NSObject *key = [self keyForSection:section];
    return [self.options objectForKey:key];
}

- (NSObject *)optionAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *key = [self keyForSection:indexPath.section];
    NSArray *array = [self.options objectForKey:key];
    return [array objectAtIndex:indexPath.row];
}

- (void)selectOptionAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return;
    
    if (![self optionAtIndexPathIsSelected:indexPath]) {
        [_indexPathsOfSelectedOptions addObject:indexPath];
        [self.tableView reloadData];
    }
}

- (void)selectOptionsAtIndexPaths:(NSArray *)indexPaths
{
    if (!indexPaths) return;
    
    for (NSIndexPath *indexPath in indexPaths) {
        if (![self optionAtIndexPathIsSelected:indexPath]) {
            [_indexPathsOfSelectedOptions addObject:indexPath];
        }
    }
    [self.tableView reloadData];
}

- (void)deselectOptionAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return;
    
    if ([self optionAtIndexPathIsSelected:indexPath]) {
        [_indexPathsOfSelectedOptions removeObject:indexPath];
        [self.tableView reloadData];
    }
}

- (void)deselectAllOptions
{
    if (_indexPathsOfSelectedOptions.count > 0) {
        [_indexPathsOfSelectedOptions removeAllObjects];
        [self.tableView reloadData];
    }
}

- (NSArray *)selectedOptions
{
    if (_indexPathsOfSelectedOptions &&
        _indexPathsOfSelectedOptions.count > 0) {
        
        NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in _indexPathsOfSelectedOptions) {
            [selectedOptions addObject:[self optionAtIndexPath:indexPath]];
        }
        return selectedOptions;
    }
    else {
        return nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.options.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self optionsForSection:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *option = [self optionAtIndexPath:indexPath];
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLBOptionCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kLBOptionCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = option.description;
	if ([self optionAtIndexPathIsSelected:indexPath])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
    
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.keyPathForTitleInHeader.length > 0) {
        
        NSObject *key = [self keyForSection:section];
        if (key) {
            return [key valueForKeyPath:self.keyPathForTitleInHeader];
        }
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL wasSelected = [self optionAtIndexPathIsSelected:indexPath];
    
	if (!wasSelected && !tableView.allowsMultipleSelection)
	{
        [self deselectAllOptions];
	}
	
    if (wasSelected) {
        [self deselectOptionAtIndexPath:indexPath];
    }
    else {
        [self selectOptionAtIndexPath:indexPath];
    }
    
    if ([self.delegate respondsToSelector:@selector(optionPickerViewController:didChangeSelectedOptions:)]) {
        [self.delegate optionPickerViewController:self didChangeSelectedOptions:self.selectedOptions];
    }
}


@end
