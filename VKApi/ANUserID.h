//
//  ANUserID.h
//  VKApi
//
//  Created by Андрей on 30.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANUserID : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSURL* imageURL;

@property (strong, nonatomic) NSString* userID;
@property (assign, nonatomic) NSString* online;
@property (assign, nonatomic) NSString* city;

-(id) initWithServerResponse:(NSDictionary*) responseObject;

@end
