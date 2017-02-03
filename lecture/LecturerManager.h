//
//  LecturerManager.h
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LecturerUser.h"
#import "Lecture.h"

@interface LecturerManager : NSObject

@property (strong, nonatomic) LecturerUser *userProfile;
@property (strong, nonatomic) NSMutableArray *lectures;
@property (strong, nonatomic) NSString *runningLectureUniqueId;

@property BOOL loginToLectureFlag;

+ (LecturerManager *)sharedInstance;


- (Lecture *)getLectureWithUniqueId:(NSString *) uniquesId;

@end
