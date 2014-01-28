//
//  LBCategoriesViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/14/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBCategoriesViewController.h"
#import "BCSite.h"
#import "BCCategory.h"

static NSString * const kLBCategoryCellIdentifier = @"CategoryCell";

@interface LBCategoriesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *categories;

@end

@implementation LBCategoriesViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.view addSubview:self.tableView];
    
    self.navigationItem.title = @"Categories";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)done:(id)sender
{
    [self.delegate categoriesViewControllerDone:self];
}

- (void)reloadCategories
{
    __weak LBCategoriesViewController *weakSelf = self;
    
    [self.site getCategoriesWithSuccess:^(NSArray *loadedCategories) {
        
        weakSelf.categories = loadedCategories;
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    } preferCached:YES];
}

- (BCCategory *)categoryAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.categories objectAtIndex:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BCCategory *category = [self categoryAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLBCategoryCellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kLBCategoryCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = category.name;
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

@end
