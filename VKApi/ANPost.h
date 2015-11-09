//
//  ANPost.h
//  VKApi
//
//  Created by Андрей on 03.11.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPost : NSObject

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString *date;
@property (assign, nonatomic) NSInteger likesCount;
@property (strong, nonatomic) NSURL *photo;

- (instancetype)initWithServerResponse:(NSDictionary*) responseObject;

@end
