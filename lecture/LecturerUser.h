//
//  LecturerUser.h
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LecturerUser : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *university;
@property (strong, nonatomic) NSString *userDescription;
@property (strong, nonatomic) NSString *userId;

-(void)createWithDictionary:(NSDictionary *)user;
-(void)updateWithDictionary:(NSDictionary *)dict;

@end
