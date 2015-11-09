//
//  ANAccessToken.h
//  VKApi
//
//  Created by Андрей on 31.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANAccessToken : NSObject

@property (strong, nonatomic)  NSString* token;
@property (strong,nonatomic) NSDate* expirationDate;
@property (strong, nonatomic) NSString* userID;

@end
