//
//  SocketConnectionManager.h
//  lecture
//
//  Created by Dusan Todorovic on 1/19/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "LecturerManager.h"

@interface SocketConnectionManager : NSObject<NSStreamDelegate>

@property BOOL connected;
@property BOOL isWaitingResponse;
@property BOOL isLoggedIn;
@property BOOL lecturer;

@property (strong, nonatomic) NSString *host;

@property (nonatomic, strong) NSMutableArray *wallQuestions;

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, strong) NSString *activeLectureId;


+ (SocketConnectionManager *)sharedInstance;

//Lecturer and Listener
//Create connection with socket
- (void) initSocketConnection;
//Close connection with socket
- (void) closeConnection;


//Lecturer
//Login Lecturer to socket after connecting
- (void)loginWithId:(NSString *)clientId;
//Start Lecture with uniqueId, password is optional
- (void)startLectureWithId:(NSString *)lectureId andPassword:(NSString *)password;
//End Lecture with uniqueId
- (void)endLectureWithId:(NSString *)lectureId;
//Send test question to listeners
- (void)sendQuestionToListenersWithQid:(NSString *)questionId andLId:(NSString *)lectureId;
//Send Listeners question to all listeners
//- (void)sendListenerQuestion:(NSString *)question toLecture:(NSString *)lectureId;
- (void)sendListenerQuestionWithId:(NSString *)questionId;
//Get results for test question
- (void)getResultsForQuestionWithId:(NSString *)questionId;
//Get number of listeners for lecture
- (void)getNumberOfListeners;
//Get all recived listeners questions for lecture
- (void)getListenersQuestions;


//Listeners
@property (strong, nonatomic) NSString *enteringLectureId;  // instade of this make new connection function for listeners
@property (strong, nonatomic) NSString *enteringLecturePassword;    // instade of this make new connection function for listeners

//Login Listener to socket after connecting
-(void)loginListener;
//Start listennig lecture with uniqueId, password is optional
- (void)listenLectureWithId:(NSString *)lectureId andPassword:(NSString *)password;
//Leave lecture
- (void)stopListenLecture;
//Send question to lecturer for active lecture
- (void)sendQuestion:(NSString *)question toLecture:(NSString *)lectureId;
//Send listeners answer for test question
- (void)sendAnswer:(NSNumber *)answer toQuestion:(NSString *)questionId;
//Get last test question from lecturer
- (void)getLastQuestion;

@end
