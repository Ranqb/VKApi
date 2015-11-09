//
//  ANServerManager.h
//  VKApi
//
//  Created by Андрей on 29.10.15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ANUserID;
@class ANAccessToken;
@interface ANServerManager : NSObject

@property (strong, nonatomic,readonly) ANUserID* user;


+(ANServerManager*) sharedManager;

-(void) authorizeUser:(void(^)(ANUserID* user)) completion;

-(void) getFriendsWithUserId:(NSString*) user
                      offset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray* friends)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getUserWithUsetID:(NSString*) userID
                onSuccess:(void(^)(ANUserID* user)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getSubscriptionsWithUser:(NSString*) user
                          offset:(NSInteger) offset
                           count:(NSInteger) count
                       onSuccess:(void(^)(NSArray* friends)) success
                       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getWall:(NSString*) user
         offset:(NSInteger) offset
          count:(NSInteger) count
      onSuccess:(void(^)(NSArray* posts)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) postText:(NSString*) text
      onGroupWall:(NSString*) groupID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
