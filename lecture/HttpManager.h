//
//  HttpManager.h
//  lecture
//
//  Created by Dusan Todorovic on 12/8/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface HttpManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSMutableDictionary *pointEnds;//URLs

+ (HttpManager *)sharedInstance;


typedef void (^GetEndPoints)(NSDictionary *endPoints);
typedef void (^RegistrationResponseBlock)(NSDictionary *regInfo);
typedef void (^LoginResponseBlock)(NSDictionary *myInfo);
typedef void (^GetUserResponseBlock)(NSDictionary *userInfo);
typedef void (^EditUserResponseBlock)(NSDictionary *editUserInfo);
typedef void (^CreateLectureResponseBlock)(NSString *lectureId);
typedef void (^EditLectureResponseBlock)(NSDictionary *lectureInfo);
typedef void (^GetLectureResponseBlock)(NSDictionary *lectureInfo);
typedef void (^CreateLecQuestionResponseBlock)(NSDictionary *questionInfo);
typedef void (^EditLecQuestionResponseBlock)(NSDictionary *questionInfo);

typedef void (^EmptyResponseBlock)(void);

typedef void (^FailureBlock)(NSError *error);


- (void)getEndPointsWithSuccessHandler:(LoginResponseBlock) success
            failureHandler:(FailureBlock)failure;

- (void)registerUserWithParameters:(NSDictionary*)parameters
            successHandler:(LoginResponseBlock)success
            failureHandler:(FailureBlock)failure;

- (void)loginUserWithEmail:(NSString*)email
                  password:(NSString*)password
            successHandler:(LoginResponseBlock)success
            failureHandler:(FailureBlock)failure;

- (void)getUserWithEmail:(NSString*)email
            successHandler:(GetUserResponseBlock)success
            failureHandler:(FailureBlock)failure;

- (void)editUserWithParameters:(NSDictionary*)parameters
                    successHandler:(EditUserResponseBlock)success
                    failureHandler:(FailureBlock)failure;

- (void)createLectureWithParameters:(NSDictionary*)parameters
                    successHandler:(CreateLectureResponseBlock)success
                    failureHandler:(FailureBlock)failure;

- (void)getLectureWithId:(NSString*)lectureId
          successHandler:(GetLectureResponseBlock)success
          failureHandler:(FailureBlock)failure;

- (void)editLectureWithParameters:(NSDictionary*)parameters
                     successHandler:(EditLectureResponseBlock)success
                     failureHandler:(FailureBlock)failure;

- (void)addQuestionWithId:(NSString *)questionId toLecture:(NSString *)lectureId
           successHandler:(EmptyResponseBlock)success
           failureHandler:(FailureBlock)failure;

- (void)removeQuestionWithId:(NSString *)questionId fromLecture:(NSString *)lectureId
              successHandler:(EmptyResponseBlock)success
              failureHandler:(FailureBlock)failure;

- (void)deleteLectureWithId:(NSString*)lectureId
                     successHandler:(EmptyResponseBlock)success
                     failureHandler:(FailureBlock)failure;

- (void)createLecQuestionWithParameters:(NSDictionary*)parameters
                     successHandler:(CreateLecQuestionResponseBlock)success
                     failureHandler:(FailureBlock)failure;

- (void)editLecQuestionWithParameters:(NSDictionary*)parameters
                         successHandler:(EditLecQuestionResponseBlock)success
                         failureHandler:(FailureBlock)failure;

- (void)getQuestionWithId:(NSString*)questionId
          successHandler:(GetUserResponseBlock)success
          failureHandler:(FailureBlock)failure;

- (void)deleteLecQuestionWithParameters:(NSDictionary*)parameters
           successHandler:(EmptyResponseBlock)success
           failureHandler:(FailureBlock)failure;
@end
