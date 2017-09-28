//
//  ListenerQuestion.h
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListenerQuestion : NSObject

@property(strong, nonatomic) NSString *guid;
@property(strong, nonatomic) NSString *question;
@property(strong, nonatomic) NSString *messageDate;
@property(strong, nonatomic) NSString *date;
@property(strong, nonatomic) NSString *lectureId;
@property BOOL sharedFlag;

-(void)fromDictionary:(NSDictionary *)dict;

@end
