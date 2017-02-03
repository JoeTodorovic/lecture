//
//  LectureQuestion.h
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LectureQuestion : NSObject

@property(strong, nonatomic) NSString *questionId;

@property(strong, nonatomic) NSString *question;
@property(strong, nonatomic) NSMutableArray *answers;
@property(strong, nonatomic) NSNumber *time;
@property(strong, nonatomic) NSNumber *correctIndex;

-(void)fromDictionary:(NSDictionary *)dict;

@end
