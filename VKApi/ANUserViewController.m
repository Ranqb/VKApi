//
//  ANUserViewController.m
//  VKApi
//
//  Created by Андрей on 30.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANUserViewController.h"
#import "ANServerManager.h"
#import "ANUserTableViewCell.h"
#import "ANUserID.h"
#import <UIImageView+AFNetworking.h>
#import "ANFriendTableViewController.h"
#import "ANSubscriptionViewController.h"
#import "ANPost.h"
#import "ANWallImageCell.h"
#import "ANWallTextCell.h"

@interface ANUserViewController ()

@property (strong, nonatomic) ANUserID* user;
@property (strong, nonatomic) NSString* cityName;
@property (strong, nonatomic) NSMutableArray* wallArray;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation ANUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    UIBarButtonItem* plus =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(postOnWall:)];
    
    self.navigationItem.rightBarButtonItem = plus;

    //self.firstTimeAppear = YES;
    self.wallArray = [NSMutableArray array];
    self.loadingData = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (self.userID){
        [[ANServerManager sharedManager]
         getUserWithUsetID:self.userID
         onSuccess:^(ANUserID *user) {
             self.user = user;
             self.cityName = user.city;
             [self getWallFromServer];
             [self.tableView reloadData];

             
         } onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
    }

    
}

- (void) getWallFromServer{
    [[ANServerManager sharedManager] getWall:self.user.userID offset:[self.wallArray count] count:15 onSuccess:^(NSArray *posts) {
        [self.wallArray addObjectsFromArray:posts];
        NSMutableArray* newPaths = [NSMutableArray array];
        for (int i = (int)[self.wallArray count] - (int)[posts count]; i < [self.wallArray count]; i++) {
            [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        self.loadingData = NO;
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld",[error localizedDescription], (long)statusCode);
        
    }];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (!self.userID && !self.firstTimeAppear) {
        self.firstTimeAppear = YES;
        [[ANServerManager sharedManager] authorizeUser:^(ANUserID *user) {
            self.user = user;
            self.cityName = user.city;
            [self.tableView reloadData];
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return [self.wallArray count];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* identifier1 = @"UserCell";
    static NSString* identifier2 = @"ImageCellWall";
    static NSString* identifier3 = @"TextCellWall";

    if (indexPath.section == 0) {
        ANUserTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
        NSInteger onlineIndicator = [self.user.online integerValue];
        
        if (onlineIndicator == 0) {
            cell.onlineLabel.text = @"Offline";
        }else{
            cell.onlineLabel.text = @"Online";
            
        }
        cell.cityLabel.text = self.cityName;
        NSURLRequest* request = [NSURLRequest requestWithURL:self.user.imageURL];
        
        __weak ANUserTableViewCell* weakCell = cell;
        
        [cell.userImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"1.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakCell.userImage.image = image;
            weakCell.userImage.layer.cornerRadius = weakCell.userImage.frame.size.width/2;
            weakCell.userImage.layer.masksToBounds = YES;
            [weakCell layoutSubviews];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        

        return cell;
    }else{
        ANPost *wall = [self.wallArray objectAtIndex:indexPath.row];
        
        if (wall.photo != nil) {
            ANWallImageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
            
            cell.textWallLabel.text = wall.text;
            
            cell.dateLabel.text = wall.date;
            cell.likesCountLabel.text = [NSString stringWithFormat:@"%ld",(long) wall.likesCount];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:wall.photo];
            
            __weak ANWallImageCell *weakCell = cell;
            
            cell.photoLabel.image = nil;
            
            [cell.imageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                           success:^(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image) {
                                               weakCell.photoLabel.image = image;
                                               [weakCell layoutSubviews];
                                           } failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
                                               
                                           }];
            
            NSURLRequest* requestUser = [NSURLRequest requestWithURL:self.user.imageURL];

            [cell.photoIDImage setImageWithURLRequest:requestUser placeholderImage:[UIImage imageNamed:@"1.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakCell.photoIDImage.image = image;
                weakCell.photoIDImage.layer.cornerRadius = weakCell.photoIDImage.frame.size.width/2;
                weakCell.photoIDImage.layer.masksToBounds = YES;
                [weakCell layoutSubviews];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
            cell.userLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];

            
            return cell;
            
        } else {
            
            ANWallTextCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
            
            cell.textWallLabel.text = wall.text;
            
            cell.dateLabel.text = wall.date;
            cell.likesCountLabel.text = [NSString stringWithFormat:@"%ld", (long)wall.likesCount];
            
            NSURLRequest* requestUser = [NSURLRequest requestWithURL:self.user.imageURL];

            
            __weak ANWallTextCell *weakCell = cell;

            [cell.photoUser setImageWithURLRequest:requestUser placeholderImage:[UIImage imageNamed:@"1.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakCell.photoUser.image = image;
                weakCell.photoUser.layer.cornerRadius = weakCell.photoUser.frame.size.width/2;
                weakCell.photoUser.layer.masksToBounds = YES;
                [weakCell layoutSubviews];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
            cell.userLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];

            
            return cell;
        }

    }

    
    return NO;
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ANUserTableViewCell class]]) {
        return 130.f;
    }
    
    if ([cell isKindOfClass:[ANWallImageCell class]]) {
        return 305.f;
    }
    
    if ([cell isKindOfClass:[ANWallTextCell class]]) {
        return 120.f;
    }
    
    return 10.f;
}
#pragma mark - Action

- (void) postOnWall:(id) sender {
    

    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Сообщение" message:@"Введите текст" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Отправить", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *name = [alertView textFieldAtIndex:0];
        [[ANServerManager sharedManager]
         postText:name.text
         onGroupWall:self.user.userID
         onSuccess:^(id result) {
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
         }];
    }
    
}

- (IBAction)userInfoAction:(UIButton *)sender {
    
    if (sender.tag == 200) {
        NSLog(@"11111");
        ANFriendTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANFriendTableViewController"];
        vc.userID = self.user.userID;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    if (sender.tag == 100) {
        ANSubscriptionViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANSubscriptionViewController"];
        vc.userID = self.user.userID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - PullToRefresh


- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:0.5 animations:^{
        cell.transform = CGAffineTransformIdentity;
    }];
}


#pragma mark - PullToRefresh


- (void)pullToRefresh {
    
    //Чтобы не испортить анимацию делаем задержку при скроле
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication]isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
        }
        [self.refreshControl endRefreshing];
        [self.wallArray removeAllObjects];
        [[ANServerManager sharedManager] getWall:self.user.userID offset:[self.wallArray count] count:15 onSuccess:^(NSArray *posts) {
            [self.wallArray addObjectsFromArray:posts];
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"error = %@, code = %ld",[error localizedDescription], (long)statusCode);
            
        }];
    });
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0) {
        
        //Чтобы не испортить анимацию делаем задержку при скроле
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            if ([[UIApplication sharedApplication]isIgnoringInteractionEvents]) {
                [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
            }
            [self getWallFromServer];
        });
    }
}


@end
