//
//  ANSubscription.m
//  VKApi
//
//  Created by Андрей on 30.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANSubscription.h"

@implementation ANSubscription

- (instancetype)initWithServerResponse:(NSDictionary*) responseObject{
    self = [super init];
    if (self) {
        
        self.name = [responseObject objectForKey:@"name"];
        self.userSubscription = [responseObject objectForKey:@"gid"];
        
        NSString* urlString = [responseObject objectForKey:@"photo_medium"];
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
        
    }
    return self;
}

@end
