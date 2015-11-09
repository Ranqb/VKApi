//
//  ViewController.m
//  VKApi
//
//  Created by Андрей on 29.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANFriendTableViewController.h"
#import "ANServerManager.h"
#import "ANFriends.h"
#import <UIImageView+AFNetworking.h>
#import "ANUserViewController.h"


@interface ANFriendTableViewController ()

@property (strong, nonatomic) NSMutableArray* friendsArray;
@property (assign,nonatomic) BOOL loadingData;


@end

static NSInteger friendsInRequest = 15;

@implementation ANFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    self.friendsArray = [NSMutableArray array];
    self.loadingData = YES;


    [self getFriendsFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - API

-(void) getFriendsFromServer {
    
    [[ANServerManager sharedManager]
     getFriendsWithUserId:self.userID
     offset:[self.friendsArray count]
     count:friendsInRequest
     onSuccess:^(NSArray *friends) {
         [self.friendsArray addObjectsFromArray:friends];
         NSMutableArray* newPaths = [NSMutableArray array];
         for (int i = (int)[self.friendsArray count] - (int)[friends count]; i < [self.friendsArray count]; i++) {
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
         [self.tableView endUpdates];
         self.loadingData = NO;

     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld",[error localizedDescription], (long)statusCode);
     }];
    
    
    
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%d",[self.friendsArray count]);
    return [self.friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    ANFriends* friend = [self.friendsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.firstName,friend.lastName];
    NSInteger onlineIndicator = [friend.onlineFlag integerValue];

    if (onlineIndicator == 0) {
        cell.detailTextLabel.text = nil;
    }else if(friend.onlineMobileFlag){
        cell.detailTextLabel.text = @"📱";
    }else{
        cell.detailTextLabel.text = @"•";

    }

    
    NSURLRequest* request = [NSURLRequest requestWithURL:friend.imageURL];
    
    __weak UITableViewCell* weakCell = cell;

    [cell.imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"1.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakCell.imageView.image = image;
        weakCell.imageView.layer.cornerRadius = weakCell.imageView.frame.size.width/2;
        weakCell.imageView.layer.masksToBounds = YES;
        [weakCell layoutSubviews];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    
    return cell;
}
#pragma mark - UITableViewDelegate 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ANUserViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANUserViewController"];
    vc.userID = [[self.friendsArray objectAtIndex:indexPath.row] userID];
    vc.firstTimeAppear = YES;
    [self.navigationController pushViewController:vc animated:YES];
        
    
}

#pragma mark - PullToRefresh


- (void)pullToRefresh {
    
    [self.refreshControl endRefreshing];
    [self getFriendsFromServer];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0) {
        [self getFriendsFromServer];
    }

}

@end
