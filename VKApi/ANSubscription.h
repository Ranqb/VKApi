//
//  ANSubscription.h
//  VKApi
//
//  Created by Андрей on 30.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANSubscription : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSURL* imageURL;
@property (strong, nonatomic) NSString* userSubscription;

-(id) initWithServerResponse:(NSDictionary*) responseObject;


@end
