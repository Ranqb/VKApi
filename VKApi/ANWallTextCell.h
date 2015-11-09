//
//  ANWallTextCell.h
//  VKApi
//
//  Created by Андрей on 03.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANWallTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *textWallLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoUser;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;



@end
