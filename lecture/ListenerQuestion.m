//
//  ListenerQuestion.m
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "ListenerQuestion.h"

@implementation ListenerQuestion

-(void)fromDictionary:(NSDictionary *)dict{
    
    if ([dict objectForKey:@"date"] != nil)
        self.messageDate = (NSString *)[dict objectForKey:@"date"];
    
    if ([dict objectForKey:@"question"] != nil) {
        NSDictionary *questionDict = [dict objectForKey:@"question"];
        if ([questionDict objectForKey:@"guid"] != nil)
            self.guid = (NSString *)[questionDict objectForKey:@"guid"];
        
        if ([questionDict objectForKey:@"question"] != nil)
            self.question = (NSString *)[questionDict objectForKey:@"question"];
        
        if ([questionDict objectForKey:@"date"] != nil)
            self.date = (NSString *)[questionDict objectForKey:@"date"];
        
        if ([questionDict objectForKey:@"lectureId"] != nil)
            self.lectureId = (NSString *)[questionDict objectForKey:@"lectureId"];
        
        if ([questionDict objectForKey:@"shared"] != nil)
            self.sharedFlag = [(NSNumber *)[questionDict objectForKey:@"shared"] boolValue];
//            self.sharedFlag = [(NSString *)[questionDict objectForKey:@"shared"]  isEqual: @"true"] ? YES : NO;
    }
}

@end
