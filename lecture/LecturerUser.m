//
//  LecturerUser.m
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LecturerUser.h"

@implementation LecturerUser

-(void)createWithDictionary:(NSDictionary *)user{
    
    if ([user objectForKey:@"firstname"] != nil)
        self.firstName = (NSString *)[user objectForKey:@"firstname"];
    
    if ([user objectForKey:@"lastname"] != nil)
        self.lastName = (NSString *)[user objectForKey:@"lastname"];
    
    if ([user objectForKey:@"email"] != nil)
        self.email = (NSString *)[user objectForKey:@"email"];
    
    if ([user objectForKey:@"title"] != nil)
        self.title = (NSString *)[user objectForKey:@"title"];
    
    if ([user objectForKey:@"description"] != nil)
        self.userDescription = (NSString *)[user objectForKey:@"description"];
    
    if ([user objectForKey:@"university"] != nil)
        self.university = (NSString *)[user objectForKey:@"university"];
    
    if ([user objectForKey:@"guid"] != nil)
        self.userId = (NSString *)[user objectForKey:@"guid"];
    
}


-(void)updateWithDictionary:(NSDictionary *)dict{
    
    if ([dict objectForKey:@"firstname"] != nil)
        self.firstName = (NSString *)[dict objectForKey:@"firstname"];
    
    if ([dict objectForKey:@"lastname"] != nil)
        self.lastName = (NSString *)[dict objectForKey:@"lastname"];
    
    if ([dict objectForKey:@"email"] != nil)
        self.email = (NSString *)[dict objectForKey:@"email"];
    
    if ([dict objectForKey:@"title"] != nil)
        self.title = (NSString *)[dict objectForKey:@"title"];
    
    if ([dict objectForKey:@"university"] != nil)
        self.university = (NSString *)[dict objectForKey:@"university"];
    
}

@end
