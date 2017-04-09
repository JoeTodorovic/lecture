//
//  Lecture.m
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "Lecture.h"

@implementation Lecture

-(void)fromDictionary:(NSDictionary *)dict{
    
    if ([dict objectForKey:@"title"] != nil)
        self.name = (NSString *)[dict objectForKey:@"title"];
    
    if ([dict objectForKey:@"description"] != nil)
        self.lectureDescription = (NSString *)[dict objectForKey:@"description"];
    
    if ([dict objectForKey:@"guid"] != nil)
        self.lectureId = (NSString *)[dict objectForKey:@"guid"];
    
    if ([dict objectForKey:@"questions"]) {
        self.questions = [[NSMutableArray alloc] init];
        for (NSDictionary *questDict in [dict objectForKey:@"questions"]) {
            LectureQuestion *question = [LectureQuestion alloc];
            [question fromDictionary:questDict];
            [self.questions addObject:question];
        }
    }
    
    if ([dict objectForKey:@"unique_id"] != nil)
        self.uniqueId = (NSString *)[dict objectForKey:@"unique_id"];
}

-(void)initQuestionsResults{
    for (LectureQuestion *question in self.questions) {
        question.results = [[NSArray alloc] init];
        question.resultsFlag = NO;
    }
}
@end
