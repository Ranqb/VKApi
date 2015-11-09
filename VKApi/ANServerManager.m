//
//  ANServerManager.m
//  VKApi
//
//  Created by Андрей on 29.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "ANServerManager.h"
#import <AFNetworking.h>
#import "ANFriends.h"
#import "ANUserID.h"
#import "ANSubscription.h"
#import "ANLoginViewController.h"
#import "ANAccessToken.h"
#import "ANPost.h"

@interface ANServerManager ()
@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@property (strong, nonatomic) ANAccessToken* accessToken;

@end

@implementation ANServerManager

+(ANServerManager*) sharedManager{
    static ANServerManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ANServerManager alloc] init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}



-(void) authorizeUser:(void(^)(ANUserID* user)) completion{
    
    ANLoginViewController* vc = [[ANLoginViewController alloc] initWithServerResponse:^(ANAccessToken *token) {
        self.accessToken = token;
        
        if (token) {
            
            [self getUserWithUsetID:self.accessToken.userID
                onSuccess:^(ANUserID *user) {
                    if (completion) {
                        completion(user);
                    }
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    if (completion) {
                        completion(nil);
                    }
                }];
            
        } else if (completion) {
            completion(nil);
        }
    }];
    
    UINavigationController* nv = [[UINavigationController alloc]initWithRootViewController:vc];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nv animated:YES completion:nil];
    
}

-(void) getFriendsWithUserId:(NSString*) user
                      offset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray* friends)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:  user,               @"user_id",
                                                                        @"hints",            @"order",
                                                                        @(count),           @"count",
                                                                        @(offset),          @"offset",
                                                                        @"photo_100,online",@"fields",
                                                                        @"nom",           @"name_case",
                                                                        @"3",               @"v",
                                                                        self.accessToken.token,              @"access_token",
                                                                        nil];
    
    
    
    [self.requestOperationManager
     GET:@"friends.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray* objectArray = [NSMutableArray array];
         for (NSDictionary* dict in dictsArray) {
             ANFriends* user = [[ANFriends alloc] initWithServerResponse:dict];
             [objectArray addObject:user];
         }
         
         if (success) {
             success(objectArray);
         }
         
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
        
    }];
    
}

-(void) getSubscriptionsWithUser:(NSString*) user
                          offset:(NSInteger) offset
                           count:(NSInteger) count
                       onSuccess:(void(^)(NSArray* friends)) success
                       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            user,           @"user_id",
                            @(1),           @"extended",
                            @(count),       @"count",
                            @(offset),      @"offset",
                            @"",            @"fields",
                            self.accessToken.token,              @"access_token",
                            nil];
    
    [self.requestOperationManager
     GET:@"users.getSubscriptions"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray* objectArray = [NSMutableArray array];
         for (NSDictionary* dict in dictsArray) {
             ANSubscription* user = [[ANSubscription alloc] initWithServerResponse:dict];
             [objectArray addObject:user];
         }
         
         if (success) {
             success(objectArray);
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

-(void) getUserWithUsetID:(NSString*) userID
                onSuccess:(void(^)(ANUserID* user)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID,                         @"user_ids",
                            @"photo_100,city,online",       @"fields",
                            @"nom",                         @"name_case",
                            @"5.37",                        @"v",
                            nil];
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         NSArray* array = [responseObject objectForKey:@"response"];
         NSDictionary* dict = [array firstObject];
         ANUserID* user = [[ANUserID alloc] initWithServerResponse:dict];

         if (success) {
             success(user);
         }

     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
}

-(void) getWall:(NSString*) user
         offset:(NSInteger) offset
          count:(NSInteger) count
      onSuccess:(void(^)(NSArray* posts)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            user,           @"owner_id",
                            @(count),       @"count",
                            @(offset),      @"offset",
                            @"all",            @"filter",
                            self.accessToken.token,              @"access_token",
                            nil];
    
    [self.requestOperationManager
     GET:@"wall.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         NSArray* array = [responseObject objectForKey:@"response"];
         
         NSMutableArray* objectArray = [NSMutableArray array];
         
         for (int i = 1; i < [array count]; i++) {
             ANPost *wall = [[ANPost alloc] initWithServerResponse:[array objectAtIndex:i]];
             [objectArray addObject:wall];
         }

         if (success) {
             success(objectArray);
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
    
}

- (void) postText:(NSString*) text
      onGroupWall:(NSString*) groupID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,       @"owner_id",
     text,          @"message",
     self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager
     POST:@"wall.post"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
    
}

@end
