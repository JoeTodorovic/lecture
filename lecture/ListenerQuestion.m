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
        if ([dict objectForKey:@"guid"] != nil)
            self.guid = (NSString *)[dict objectForKey:@"guid"];
        
        if ([dict objectForKey:@"question"] != nil)
            self.question = (NSString *)[dict objectForKey:@"question"];
        
        if ([dict objectForKey:@"date"] != nil)
            self.date = (NSString *)[dict objectForKey:@"date"];
        
        if ([dict objectForKey:@"lectureId"] != nil)
            self.lectureId = (NSString *)[dict objectForKey:@"lectureId"];
        
        if ([dict objectForKey:@"shared"] != nil)
            self.sharedFlag = (NSString *)[dict objectForKey:@"shared"];

    }
}

@end
