//
//  ANWallImageCell.h
//  VKApi
//
//  Created by Андрей on 03.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANWallImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoLabel;
@property (weak, nonatomic) IBOutlet UILabel *textWallLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoIDImage;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;



@end
