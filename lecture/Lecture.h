//
//  Lecture.h
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LectureQuestion.h"

@interface Lecture : NSObject

@property(strong, nonatomic) NSString *lectureId;
@property(strong, nonatomic) NSString *uniqueId;//this id is used for socket and listeners enter lecture with this id

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *lectureDescription;
@property(strong, nonatomic) NSString *password;

@property(strong, nonatomic) NSMutableArray *questions;

-(void)fromDictionary:(NSDictionary *)dict;

-(void)initQuestionsResults;//init results array for every question


@end
