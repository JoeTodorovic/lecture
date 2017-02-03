//
//  LectureQuestion.m
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LectureQuestion.h"

@implementation LectureQuestion


-(void)fromDictionary:(NSDictionary *)dict{
    
    if ([dict objectForKey:@"guid"] != nil)
        self.questionId = (NSString *)[dict objectForKey:@"guid"];
    
    if ([dict objectForKey:@"question"] != nil)
        self.question = (NSString *)[dict objectForKey:@"question"];
    
    if ([dict objectForKey:@"correctindex"] != nil){
        
        self.correctIndex = (NSNumber *)[dict objectForKey:@"correctindex"];
        
        NSLog(@"%@", self.correctIndex);
    }
    if ([dict objectForKey:@"duration"] != nil)
        self.time = (NSNumber *)[dict objectForKey:@"duration"];
    
    if ([dict objectForKey:@"answers"]){
//        self.answers = [[NSMutableArray alloc] initWithArray:(NSArray*)[dict objectForKey:@"answers"]];
        if (self.answers == nil) 
            self.answers = [[NSMutableArray alloc] init];
        self.answers = [(NSArray *)[dict objectForKey:@"answers"] mutableCopy];
        
    }
}

@end
