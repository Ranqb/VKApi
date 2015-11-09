//
//  ANSubscriptionViewController.m
//  VKApi
//
//  Created by Андрей on 30.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANSubscriptionViewController.h"
#import "ANServerManager.h"
#import "ANSubscription.h"
#import <UIImageView+AFNetworking.h>
#import "ANUserViewController.h"

@interface ANSubscriptionViewController ()
@property (strong, nonatomic) NSMutableArray* subscriptionArray;
@property (assign,nonatomic) BOOL loadingData;
@end
static NSInteger friendsInRequest = 15;

@implementation ANSubscriptionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.subscriptionArray = [NSMutableArray array];
    self.loadingData = YES;
    if (!self.userID) {
        self.userID = @"134187741";
    }
    
    [self getSubscriptionFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - API

-(void) getSubscriptionFromServer {
    
    [[ANServerManager sharedManager]
     getSubscriptionsWithUser:self.userID
     offset:[self.subscriptionArray count]
     count:friendsInRequest
     onSuccess:^(NSArray *friends) {
         [self.subscriptionArray addObjectsFromArray:friends];
         NSMutableArray* newPaths = [NSMutableArray array];
         for (int i = (int)[self.subscriptionArray count] - (int)[friends count]; i < [self.subscriptionArray count]; i++) {
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
    NSLog(@"%d",[self.subscriptionArray count]);
    return [self.subscriptionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    ANSubscription* subscription = [self.subscriptionArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = subscription.name;
    
    NSURLRequest* request = [NSURLRequest requestWithURL:subscription.imageURL];
    
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

//    
//    ANUserViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANUserViewController"];
//    vc.userID = [[self.subscriptionArray objectAtIndex:indexPath.row] userSubscription];
//    [self.navigationController pushViewController:vc animated:YES];
    
    
}
#pragma mark - PullToRefresh


- (void)pullToRefresh {
    
    [self.refreshControl endRefreshing];
    [self getSubscriptionFromServer];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0) {
        [self getSubscriptionFromServer];
    }

}


@end
