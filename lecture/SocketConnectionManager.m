//
//  SocketConnectionManager.m
//  lecture
//
//  Created by Dusan Todorovic on 1/19/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import "SocketConnectionManager.h"

typedef enum {
    Login, StartLecture, EndLecture, SendLecturerQuestion, DisplayListenerQuestion, GetResultsForQuestion, ListenLecture, StopListeningLecture, SendListenerQuestion, SendAnswer
} ClientAction;

@implementation SocketConnectionManager{
    
    BOOL startLecture;
    ClientAction lastAction;
}

+ (SocketConnectionManager *)sharedInstance {
    __strong static SocketConnectionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SocketConnectionManager alloc] init];
        sharedInstance.connected = NO;
        sharedInstance.isWaitingResponse = NO;
        sharedInstance.isLoggedIn = NO;
    });
    
    return sharedInstance;
    
}

#pragma mark - Sockets

- (void)initSocketConnection{
    
    if (!self.connected) {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"89.216.252.17", 8210, &readStream, &writeStream);
        
        self.inputStream = (__bridge_transfer NSInputStream*) readStream;
        self.outputStream = (__bridge_transfer NSOutputStream*) writeStream;
        
        [self.inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self.inputStream open];
        [self.outputStream open];
        
        NSLog(@"init DONE!");
    }
    else{
        NSDictionary *actionResponse = @{@"status" : [NSNumber numberWithBool:YES]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"socketConnectionResponseNotification" object:nil userInfo:actionResponse];
    }
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    if ([theStream isEqual:self.inputStream]){
        NSLog(@"INPUT stream");
    }
    if ([theStream isEqual:self.outputStream]){
        NSLog(@"OUTPUT stream");
    }
    
    NSLog(@"stream event %lu", (unsigned long)streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == self.inputStream) {
                
                uint8_t buffer[65536];
                int len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = (int)[self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSData* inputData= [NSData dataWithBytes:buffer length:len];
                        
                        NSError* error = [NSError new];
                        NSDictionary* socketJson = [NSJSONSerialization
                                              JSONObjectWithData:inputData
                                              
                                              options:kNilOptions
                                              error:&error];
                        
                        NSLog(@"input JSON:%@", socketJson);
                        
                        if (socketJson != nil) {
                            
                            NSString *type = (NSString *)[socketJson valueForKey:@"type"];
                            
                            
                            if ([type isEqualToString:@"message"]) {
                                
                                NSLog(@"Socket Message:");
                                NSMutableDictionary *messageInfo = [[NSMutableDictionary alloc] init];

                                NSString *action = (NSString *)[socketJson valueForKey:@"method"];
                                
                                if ([action isEqualToString:@"LOGIN"]) {
                                    
                                    NSLog(@"%@", action);
                                    NSLog(@"%@", (NSString *)[socketJson valueForKey:@"message"]);
                                    self.connected = YES;
                                    
//                                    [self loginWithId:[LecturerManager sharedInstance].userProfile.userId];
//                                    NSDictionary *actionResponse = @{@"status" : [NSNumber numberWithBool:YES]};
                                    messageInfo = (NSMutableDictionary *)@{@"status" : [NSNumber numberWithBool:YES]};
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"socketConnectionResponseNotification" object:nil userInfo:messageInfo];
                                }
                                
                                //for LECTURER
                                if ([action isEqualToString:@"LISTENERSENTQUESTION"]) {
                                    NSLog(@"Listener_Sent_Question");
//                                    NSLog(@"%@", (NSString *)[json valueForKey:@"message"]);
                                    if ([socketJson valueForKey:@"message"]) {
                                        [self.wallQuestions addObject:[socketJson valueForKey:@"message"]];
                                    }
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"listenerSentQuestionNotification" object:nil userInfo:nil];
                                }
                                
                                //for LISTENER
                                if ([action isEqualToString:@"STOPPEDLECTURE"]) {
                                    NSLog(@"Lecturer_Stoped_Lecture");
//                                    NSLog(@"%@", (NSString *)[json valueForKey:@"message"]);
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"lectureFinishedNotification" object:nil userInfo:nil];
                                }
                                
                                if ([action isEqualToString:@"LECTURERSENTQUESTION"]) {
                                    NSLog(@"Lecturer_Sent_Question");
                                    
                                    if ([socketJson valueForKey:@"message"]) {
                                        messageInfo = (NSMutableDictionary *)@{@"message" : [socketJson objectForKey:@"message"]};
                                    }
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"lecturerSentQuestionNotification" object:nil userInfo:messageInfo];
                                }
                                
                                if ([action isEqualToString:@"LECTURERSENTLISTENERQUESTION"]) {
                                    NSLog(@"Lecturer_Displayed_Question");

                                    if ([socketJson valueForKey:@"message"]) {
                                        [self.wallQuestions addObject:[socketJson valueForKey:@"message"]];
                                        messageInfo = (NSMutableDictionary *)@{@"message" : [socketJson objectForKey:@"message"]};
                                    }
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"listenerDisplyedQuestionNotification" object:nil userInfo:messageInfo];
                                }
                                
                            }
                            else{
                                if ([type isEqualToString:@"response"]) {
                                    
                                    NSMutableDictionary *actionResponse = [[NSMutableDictionary alloc] init];
                                    NSNumber *ok = (NSNumber *)[socketJson valueForKey:@"ok"];
                                    BOOL status = [ok boolValue];
                                    [actionResponse setValue:(NSNumber *)[socketJson valueForKey:@"ok"] forKey:@"status"];
                                    
                                    NSString *respone_message = (NSString *)[socketJson valueForKey:@"message"];
                                    NSLog(@"Action: %@", [self enumToString:lastAction]);
//                                    NSLog(@"status: %@", [actionResponse valueForKey:@"status"]);
//                                    NSLog(@"Socket respone: %@", respone_message);
                                    
                                    switch (lastAction) {
                                            
                                        case Login:
                                            
                                            NSLog(self.isLoggedIn ? @"LoggedIn: Yes" : @"LoggedIn: No");

                                            if (status) {
                                                self.isLoggedIn = YES;
                                            }
                                            
                                            [actionResponse setValue:respone_message forKey:@"message"];
                                            self.isWaitingResponse = NO;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponseNotification" object:actionResponse userInfo:actionResponse];
                                            break;
                                            
                                            
                                        //LECTURER responses
                                        case StartLecture:
                                            
                                            self.isWaitingResponse = NO;
                                            
                                            if (status) {
                                                self.wallQuestions = [[NSMutableArray alloc] init];
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"startLectureResponseNotification" object:nil userInfo:actionResponse];
                                            }
                                            else{
                                                self.wallQuestions = [[NSMutableArray alloc] init];
                                                if ([respone_message isEqualToString:@"lecture already started"]) {
                                                    [actionResponse setValue:[NSNumber numberWithBool:YES] forKey:@"status"];
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"startLectureResponseNotification" object:nil userInfo:actionResponse];
                                                }
                                                else{
                                                    self.activeLectureId = nil;
                                                }
                                            }

                                            break;
                                            
                                        case EndLecture:
                                            
                                            self.isWaitingResponse = NO;
                                            if (status) {
                                                self.wallQuestions = nil;
                                                self.activeLectureId = nil;
                                                }

                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"endLectureResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                        case SendLecturerQuestion:
                                            
                                            self.isWaitingResponse = NO;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendLecturerQuestionResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                        case DisplayListenerQuestion:
                                            
                                            self.isWaitingResponse = NO;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"displayListenerQuestionResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                        case GetResultsForQuestion:
                                            
                                            self.isWaitingResponse = NO;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getResultsForQuestionResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                            
                                        //LISTENER responses
                                            
                                        case ListenLecture:
                                            
                                            self.isWaitingResponse = NO;
                                            
                                            if (status) {
                                                self.wallQuestions = [[NSMutableArray alloc] init];
                                            }
                                            else{
                                                self.activeLectureId = nil;
                                            }
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"listenLectureResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                        case StopListeningLecture:
                                            
                                            self.isWaitingResponse = NO;
                                            
                                            if (status) {
                                                self.wallQuestions = nil;
                                                self.activeLectureId = nil;
                                            }
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopListeningLectureResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                        case SendListenerQuestion:
                                            
                                            self.isWaitingResponse = NO;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendListenerQuestionResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                        case SendAnswer:
                                            
                                            self.isWaitingResponse = NO;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendAnswerResponseNotification" object:nil userInfo:actionResponse];
                                            break;
                                            
                                        default:
                                            break;
                                    }
                                    
                                    
                                }
                                else
                                {
                                    NSLog(@"Unknown socket type: %@", type);
                                    
                                }
                                
                            }
                        }
                    }
                }
            }
            break;
            
            
        case NSStreamEventErrorOccurred:
            {
            NSLog(@"Can not connect to the host!");
            self.connected = NO;
                NSDictionary *actionResponse = @{@"status" : [NSNumber numberWithBool:NO]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"socketConnectionResponseNotification" object:nil userInfo:actionResponse];
            
            }
            break;
            
            case NSStreamEventHasSpaceAvailable:
            
            NSLog(@"has space available");
            break;
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            
            
            break;
        case NSStreamEventNone:
            NSLog(@"event none");
        default:
            NSLog(@"Unknown event");
            break;
    }
    
}

#pragma mark - Methods

#pragma mark - Lecturer Methods


- (void) closeConnection{
    
//    if (self.activeLectureId != nil) {
//        [self endLectureWithId:self.activeLectureId];
//    }
    
    NSDictionary *parameters = @{@"method":@"close"};
    
    NSError *error;
    NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                          options:0
                                                            error:&error] mutableCopy];
    const char* newLine = "\n";
    [data appendBytes:newLine length:1];
    
    [self.outputStream write:[data bytes] maxLength:[data length]];
    
//    const char* newLine = "\n";
//    [self.outputStream write:(const uint8_t*)newLine maxLength:1];
    
    [self.inputStream close];
    [self.outputStream close];
    
    self.activeLectureId = nil;
    self.connected = NO;
    self.isLoggedIn = NO;
    self.isWaitingResponse = NO;
    NSLog(@"Closed socket connection");
}

-(void)loginWithId:(NSString *)clientId{
    
    if (!self.isWaitingResponse) {
        if (!self.isLoggedIn) {
            
            NSDictionary *parameters = @{@"method": @"login", @"params":clientId};
            
            NSError *error;
            NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                                  options:0
                                                                    error:&error] mutableCopy];
            const char* newLine = "\n";
            [data appendBytes:newLine length:1];
            
            [self.outputStream write:[data bytes] maxLength:[data length]];
            
            lastAction = Login;
            self.isWaitingResponse = YES;
            
            NSLog(@"login with uid : %@", clientId);
        }
        else{
            NSDictionary *actionResponse = @{@"status": @"1"};
            self.isWaitingResponse = NO;
            
            NSLog(@"Already logged in. Continue");

            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponseNotification" object:actionResponse userInfo:actionResponse];
        }
    }

}

- (void)startLectureWithId:(NSString *)lectureId andPassword:(NSString *)password{
    
    
    if (!self.isWaitingResponse) {
        
        self.activeLectureId = [[NSString alloc] initWithString:lectureId];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:lectureId forKey:@"id"];
        if (password != nil)
            [dict setValue:password forKey:@"password"];
        
        
        NSDictionary *parameters  = @{@"method":@"startLecture", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = StartLecture;
        self.isWaitingResponse = YES;
        
        NSLog(@"start lecture sent");
    }

}

- (void)endLectureWithId:(NSString *)lectureId{
    
    if (!self.isWaitingResponse) {
        NSDictionary *dict = @{@"id": lectureId};
        NSDictionary *parameters = @{@"method":@"stopLecture", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = EndLecture;
        self.isWaitingResponse = YES;
        
        NSLog(@"end lecture sent");

    }
}

- (void)sendQuestionToListenersWithQid:(NSString *)questionId andLId:(NSString *)lectureId{
    
    if (!self.isWaitingResponse) {
        NSDictionary *dict = @{@"lectureId":lectureId, @"questionId": questionId};
        NSDictionary *parameters  = @{@"method":@"sendQuestionToListeners", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = SendLecturerQuestion;
        self.isWaitingResponse = YES;
    }

}

- (void)sendListenerQuestion:(NSString *)question toLecture:(NSString *)lectureId{
    
    if (!self.isWaitingResponse) {
        NSDictionary *dict = @{@"lectureId":lectureId, @"questionText": question};
        NSDictionary *parameters  = @{@"method":@"sendListenerQuestionToListeners", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = DisplayListenerQuestion;
        self.isWaitingResponse = YES;
    }
    
}

- (void)getResultsForQuestionWithId:(NSString *)questionId{
 
    if (!self.isWaitingResponse) {
        NSDictionary *dict = @{@"questionId": questionId };
        NSDictionary *parameters  = @{@"method":@"getAnswersToQuestion", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = GetResultsForQuestion;
        self.isWaitingResponse = YES;
    }
}

#pragma mark - Listener Methods

-(void)loginListener{
    
    if (!self.isWaitingResponse) {
        if (!self.isLoggedIn) {
            
            NSDictionary *parameters = @{@"method": @"login", @"params":@"LISTENER"};
            
            NSError *error;
            NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                                  options:0
                                                                    error:&error] mutableCopy];
            const char* newLine = "\n";
            [data appendBytes:newLine length:1];
            
            [self.outputStream write:[data bytes] maxLength:[data length]];
            
            lastAction = Login;
            self.isWaitingResponse = YES;
            
            NSLog(@"login LISTENER");
        }
        else{
            NSDictionary *actionResponse = @{@"status": @"1"};
            self.isWaitingResponse = NO;
            
            NSLog(@"Already logged in. Continue");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponseNotification" object:actionResponse userInfo:actionResponse];
        }
    }
    
}

- (void)listenLectureWithId:(NSString *)lectureId andPassword:(NSString *)password{
    
    if (!self.isWaitingResponse) {
        
        self.activeLectureId = [[NSString alloc] initWithString:lectureId];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:lectureId forKey:@"id"];
        if (password != nil)
            [dict setValue:password forKey:@"password"];
        
        
        NSDictionary *parameters  = @{@"method":@"listenLecture", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = ListenLecture;
        self.isWaitingResponse = YES;
    }
    
}


- (void)stopListenLecture{
    
    if (!self.isWaitingResponse) {
        NSDictionary *parameters  = @{@"method":@"stopListenLecture"};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = StopListeningLecture;
        self.isWaitingResponse = YES;
    }
    
}

- (void)sendQuestion:(NSString *)question toLecture:(NSString *)lectureId{
    
    if (!self.isWaitingResponse) {
        NSDictionary *dict = @{@"lectureId":lectureId, @"questionText": question};
        NSDictionary *parameters  = @{@"method":@"sendQuestionToLecturer", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = SendListenerQuestion;
        self.isWaitingResponse = YES;
    }
    
}

- (void)sendAnswer:(NSNumber *)answer toQuestion:(NSString *)questionId{
    
    if (!self.isWaitingResponse) {
        NSDictionary *dict = @{@"answerIndex": answer, @"questionId": questionId};
        NSDictionary *parameters  = @{@"method":@"sendAnswerToQuestion", @"params": dict};
        
        NSError *error;
        NSMutableData *data= [[NSJSONSerialization dataWithJSONObject:parameters
                                                              options:0
                                                                error:&error] mutableCopy];
        const char* newLine = "\n";
        [data appendBytes:newLine length:1];
        
        
        [self.outputStream write:[data bytes] maxLength:[data length]];
        
        lastAction = SendAnswer;
        self.isWaitingResponse = YES;
    }
    
}


- (NSString*)enumToString:(ClientAction) action {
    NSString *result = nil;
    
    switch(action) {
        case Login:
            result = @"LOGIN action Response";
            break;
        case StartLecture:
            result = @"StartLecture action Response";
            break;
        case EndLecture:
            result = @"EndLecture action Response";
            break;
            
        default:
            result = @"unknown";
    }
    
    return result;
}

@end
