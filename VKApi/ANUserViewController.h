//
//  ANUserViewController.h
//  VKApi
//
//  Created by Андрей on 30.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANUserViewController : UITableViewController

@property (strong, nonatomic) NSString* userID;
@property (assign, nonatomic) BOOL firstTimeAppear;

- (IBAction)userInfoAction:(UIButton *)sender;

@end
