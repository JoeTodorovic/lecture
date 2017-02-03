//
//  LecturerManager.m
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LecturerManager.h"

@implementation LecturerManager


+ (LecturerManager *)sharedInstance{
    __strong static LecturerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LecturerManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    if ((self = [super init])) {
        
        self.lectures = [[NSMutableArray alloc] init];
        self.loginToLectureFlag = NO;
    }
    return self;
}

- (Lecture *)getLectureWithUniqueId:(NSString *) uniquesId{
    
    for (Lecture *lecture in self.lectures) {
        if ([lecture.uniqueId isEqualToString:uniquesId]) {
            return lecture;
        }
    }
    
    return nil;
}

@end
