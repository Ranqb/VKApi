//
//  ANUserID.m
//  VKApi
//
//  Created by Андрей on 30.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANUserID.h"

@implementation ANUserID

- (instancetype)initWithServerResponse:(NSDictionary*) responseObject{
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        self.userID = [responseObject objectForKey:@"id"];
        self.online = [responseObject objectForKey:@"online"];
        self.city = [[responseObject objectForKey:@"city"] objectForKey:@"title"];
        
        NSString* urlString = [responseObject objectForKey:@"photo_100"];
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
        
    }
    return self;
}

@end
