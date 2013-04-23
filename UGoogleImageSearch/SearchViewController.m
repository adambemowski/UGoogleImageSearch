//
//  ViewController.m
//  UGoogleImageSearch
//
//  Created by Adam Bemowski on 4/21/13.
//  Copyright (c) 2013 BEMO. All rights reserved.
//


#import "SearchViewController.h"
#import "UImageNetworking.h" //Not very well named, possibly refactor later.
#import "GoogleImageCell.h"


@interface SearchViewController ()
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UITableView *previousSearchesTableView;
@property (nonatomic, weak) IBOutlet UICollectionView *searchCollectionView;

@property (nonatomic) NSString *searchTerm;
@property (nonatomic) NSMutableDictionary *searchResults;
@property (nonatomic) NSMutableArray *searches;
@property (nonatomic) int currentPage;
@property (nonatomic) BOOL isLoading;
@end


@implementation SearchViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searches = [NSMutableArray array];
    self.searchResults = [NSMutableDictionary dictionary];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.previousSearchesTableView.hidden = YES;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - API

-(void)startSearch
{
    self.isLoading = YES;
    
    if (self.currentPage >= 7) return; //only need to display minimum of 50.
    
    [[UImageNetworking sharedClient] getImagesForSearch:self.searchTerm page:self.currentPage success:^(NSArray *response){
        
        NSMutableArray *searchResonse = [NSMutableArray arrayWithArray:response];
        
        if ([self.searches containsObject:self.searchTerm]) {
            NSMutableArray *tempArray = [self.searchResults objectForKey:self.searchTerm];
            [tempArray addObjectsFromArray:searchResonse];
            searchResonse = tempArray;
        } else {
            [self.searches insertObject:self.searchTerm atIndex:0];
        }
        
        [self.searchResults setObject:searchResonse forKey:self.searchTerm];
        
        //If we are on the first/second page of results, just load more automatically since it's only 8 per page.
        self.currentPage++;
        if (self.currentPage <= 2) {
            [self startSearch];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchCollectionView reloadData];
            });
        }
        
        self.isLoading = NO;
        
    }failure:^(NSError *error){
        // show error message
        
        self.isLoading = NO;
    }];
}


#pragma mark - UITablview Datasource and Delegate Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searches.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 24;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.searches objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchTextField resignFirstResponder];
    
    self.searchTerm = [self.searches objectAtIndex:indexPath.row];
    self.searchTextField.text = self.searchTerm;
    
    [self displayResultsIfCached];
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -15 && self.isLoading == NO) {
        [self startSearch];
    }
}


#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.isLoading = NO;

    self.searchTerm = textField.text;
    
    [self displayResultsIfCached];
    
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.isLoading = YES; //to keep tableview from triggering load more.
    self.previousSearchesTableView.hidden = NO;
    [self.previousSearchesTableView reloadData];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.isLoading = NO;
    self.previousSearchesTableView.hidden = YES;
}


#pragma mark - UICollectionView Datasource and Delegates and Flow Layout

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    NSArray *searchResultsArray = [self.searchResults objectForKey:self.searchTerm];
    if (searchResultsArray != nil) {
        return searchResultsArray.count;
    }
    return 0;
}


- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoogleImageCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"googleImageCell" forIndexPath:indexPath];
    [cell setCellImageWithURL:[[[self.searchResults objectForKey:self.searchTerm] objectAtIndex:indexPath.row] objectForKey:@"tbUrl"]];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(96, 96);
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


#pragma mark - Helpers

- (void)displayResultsIfCached
{
    if ([self.searches containsObject:self.searchTerm]) {
        NSMutableArray *tempArray = [self.searchResults objectForKey:self.searchTerm];
        self.currentPage = tempArray.count/8;
        
        [self.searchCollectionView reloadData];
    } else {
        self.currentPage = 0;
        [self startSearch];
    }
}

@end
