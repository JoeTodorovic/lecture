    //
//  HttpManager.m
//  lecture
//
//  Created by Dusan Todorovic on 12/8/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "HttpManager.h"

@implementation HttpManager


+ (HttpManager *)sharedInstance {
    __strong static HttpManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HttpManager alloc] init];
    });
    
    return sharedInstance;
    
}


- (id)init {
    if ((self = [super init])) {
        
//        self.host = @"localhost";
        self.host = @"192.168.0.12";
//        self.host = @"24.135.56.76";


        self.pointEnds = [[NSMutableDictionary alloc] init];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        self.sessionManager = manager;
        
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
    }
    return self;
}





- (void)getEndPointsWithSuccessHandler:(LoginResponseBlock)success failureHandler:(FailureBlock)failure{
//    @"http://localhost:8000/home"
    
    [self.sessionManager GET:[NSString stringWithFormat:@"http://%@:8000/home", self.host] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"GET_EndPoints successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"GET_EndPoints response: %@", responseJSON);
        
        self.pointEnds = [responseJSON mutableCopy];
        
        for (int i=0; i<[[self.pointEnds allKeys] count]; i++) {
            
            NSString *value = self.pointEnds.allValues[i];
            NSString *key = self.pointEnds.allKeys[i];

            value = [value stringByReplacingOccurrencesOfString:@"24.135.42.105" withString:self.host];
            [self.pointEnds setValue:value forKey:key];
        }
        
        success(responseJSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        NSLog(@"GET_EndPoints fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"GET_EndPoints error:%@", errResponse);

        failure(error);
    }];
    
}


- (void)registerUserWithParameters:(NSDictionary*)parameters
                      successHandler:(LoginResponseBlock)success
                      failureHandler:(FailureBlock)failure{
    
    
    NSString *registrationURL = [NSString stringWithString:[self.pointEnds objectForKey:@"user"]];
    
    [self.sessionManager POST:registrationURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"REGISTER_USER successful");
        NSDictionary *responseJSON = [[NSDictionary alloc] init];

        responseJSON = (NSDictionary *)responseObject;
        NSLog(@"REGISTER_USER response: %@", responseJSON);
        
        
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        
        NSLog(@"REGISTER_USER fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"REGISTER_USER error:%@",errResponse);
        
        failure(error);
    }];
}




#pragma mark - USER

- (void)loginUserWithEmail:(NSString*)email
                  password:(NSString*)password
            successHandler:(LoginResponseBlock)success
            failureHandler:(FailureBlock)failure{
    
    NSString *loginURL = [NSString stringWithString:(NSString *)[self.pointEnds objectForKey:@"login"]];
    NSDictionary *parameters =@{@"email" : email,
                                @"password" : password};
    
    [self.sessionManager POST:loginURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"LOGIN successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"LOGIN response: %@", responseJSON);
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSString *token = [NSString stringWithString:[httpResponse.allHeaderFields objectForKey:@"Jwt"]];
//            NSString *encoded = [token stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"Jwt"];

            NSLog(@"TOKEN added to header: %@", token);
        }
        
        self.sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];

        
        success(responseJSON);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"LOGIN fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"LOGIN error:%@",errResponse);

        failure(error);
    }];
}

- (void)getUserWithEmail:(NSString*)email
          successHandler:(GetUserResponseBlock)success
          failureHandler:(FailureBlock)failure{
    
    NSString *getUserURL = [[NSString stringWithString:[self.pointEnds objectForKey:@"user-get"]] stringByReplacingOccurrencesOfString:@"{email}" withString:email];
    
    [self.sessionManager GET:getUserURL parameters:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"GET_USER successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"GET_USER response: %@", responseJSON);
        
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"GET_USER fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"GET_USER error:%@", errResponse);

        failure(error);
    }];
}

-(void)editUserWithParameters:(NSDictionary *)parameters
               successHandler:(EditUserResponseBlock)success
               failureHandler:(FailureBlock)failure{
    
    NSString *editUserURL = [NSString stringWithString:[self.pointEnds objectForKey:@"user"]];
    
//    NSMutableDictionary *editParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
//    [editParameters setValue:@"replace" forKey:@"op"];
    
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    [self.sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
//                                                       options:NSJSONWritingPrettyPrinted error:&error];
//    NSString* aStr;
//    aStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self.sessionManager PATCH:editUserURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"EDIT_USER successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"EDIT response: %@", responseJSON);
        
        
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"EDIT_USER fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"EDIT_USER error:%@", errResponse);

        failure(error);
    }];
}




#pragma mark - LECTURE

- (void)createLectureWithParameters:(NSDictionary*)parameters
                    successHandler:(CreateLectureResponseBlock)success
                    failureHandler:(FailureBlock)failure{
    
    
    NSString *createLectureURL = [NSString stringWithString:[self.pointEnds objectForKey:@"lecture"]];
    
    [self.sessionManager POST:createLectureURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"CREATE_LECTURE successful");
        NSDictionary *responseJSON = [[NSDictionary alloc] init];
        
        responseJSON = (NSDictionary *)responseObject;
        NSLog(@"CREATE_LECTURE response: %@", responseJSON);
        
        NSString *lectureId = [NSString stringWithString:[responseJSON objectForKey:@"id"]];
        
        success(lectureId);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        NSLog(@"CREATE_LECTURE fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"CREATE_LECTURE error:%@",errResponse);
        
        failure(error);
    }];
}

-(void)editLectureWithParameters:(NSDictionary*)parameters
                   successHandler:(EditLectureResponseBlock)success
                   failureHandler:(FailureBlock)failure{
    
    NSString *editLectureURL = [NSString stringWithString:[self.pointEnds objectForKey:@"lecture"]];
    
    NSMutableDictionary *editParameters = [[NSMutableDictionary alloc] init];
    [editParameters setValue:@"replace" forKey:@"op"];
    [editParameters setObject:parameters forKey:@"parameters"];
    [editParameters setValue:[parameters valueForKey:@"guid"] forKey:@"path"];
    
    [self.sessionManager PATCH:editLectureURL parameters:editParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"EDIT_LECTURE successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"EDIT_LECTURE response: %@", responseJSON);
        
        
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"EDIT_LECTURE fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"EDIT_LECTURE error:%@", errResponse);
        
        failure(error);
    }];
}

- (void)getLectureWithId:(NSString*)lectureId
          successHandler:(GetLectureResponseBlock)success
          failureHandler:(FailureBlock)failure{
    
    NSString *getLectureURL = [[NSString stringWithString:[self.pointEnds objectForKey:@"lecture-get"]] stringByReplacingOccurrencesOfString:@"{id}" withString:lectureId];
    
    [self.sessionManager GET:getLectureURL parameters:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"GET_LECTURE successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"GET_LECTURE response: %@", responseJSON);
        
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"GET_LECTURE fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"GET_LECTURE error:%@", errResponse);
        
        failure(error);
    }];
}

- (void)addQuestionWithId:(NSString *)questionId toLecture:(NSString *)lectureId
           successHandler:(EmptyResponseBlock)success
           failureHandler:(FailureBlock)failure{
    
    NSString *addQuestionURL = [NSString stringWithString:[self.pointEnds objectForKey:@"lecture"]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *qp = [[NSMutableDictionary alloc] init];
    [qp setValue:questionId forKey:@"questionId"];
    
    [parameters setValue:@"add" forKey:@"op"];
    [parameters setValue:lectureId forKey:@"path"];
    [parameters setObject:qp forKey:@"parameters"];
    
    [self.sessionManager PATCH:addQuestionURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"ADD_QUESTION successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"ADD_QUESTION response: %@", responseJSON);
        
        success();
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"ADD_QUESTION fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"ADD_QUESTION error:%@", errResponse);
        
        failure(error);
    }];
}

- (void)removeQuestionWithId:(NSString *)questionId
                 fromLecture:(NSString *)lectureId
              successHandler:(EmptyResponseBlock)success
              failureHandler:(FailureBlock)failure{
    
    NSString *addQuestionURL = [NSString stringWithString:[self.pointEnds objectForKey:@"lecture"]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *qp = [[NSMutableDictionary alloc] init];
    [qp setValue:questionId forKey:@"questionId"];
    
    [parameters setValue:@"remove" forKey:@"op"];
    [parameters setValue:lectureId forKey:@"path"];
    [parameters setObject:qp forKey:@"parameters"];
    
    [self.sessionManager PATCH:addQuestionURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"REMOVE_QUESTION successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"REMOVE_QUESTION response: %@", responseJSON);
        
        success();
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"REMOVE_QUESTION fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"REMOVE_QUESTION error:%@", errResponse);
        
        failure(error);
    }];
}


- (void)deleteLectureWithId:(NSString*)lectureId
                         successHandler:(EmptyResponseBlock)success
                         failureHandler:(FailureBlock)failure{
    
    NSString *deleteLectureURL = [NSString stringWithString:[self.pointEnds objectForKey:@"lecture"]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:lectureId,@"id", nil];
    
//    self.sessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    
    [self.sessionManager DELETE:deleteLectureURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"DELETE_LECTURE successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"DELETE_LECTURE response: %@", responseJSON);
        
//        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        success();
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"DELETE_LECTURE fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"DELETE_LECTURE error:%@", errResponse);
        
//        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        failure(error);
    }];
}


#pragma mark - QUESTION

- (void)createLecQuestionWithParameters:(NSDictionary*)parameters
                     successHandler:(CreateLecQuestionResponseBlock)success
                     failureHandler:(FailureBlock)failure{
    
    
    NSString *createLecQuestionURL = [NSString stringWithString:[self.pointEnds objectForKey:@"question"]];
    
    [self.sessionManager POST:createLecQuestionURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"CREATE_LEC_QUESTION successful");
        NSDictionary *responseJSON = [[NSDictionary alloc] init];
        
        responseJSON = (NSDictionary *)responseObject;
        NSLog(@"CREATE_LEC_QUESTION response: %@", responseJSON);
        
        
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        NSLog(@"CREATE_LEC_QUESTION fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"CREATE_LEC_QUESTION error:%@",errResponse);
        
        failure(error);
    }];
}

- (void)editLecQuestionWithParameters:(NSDictionary*)parameters
                       successHandler:(EditLecQuestionResponseBlock)success
                       failureHandler:(FailureBlock)failure{
    
    NSString *editQuestionURL = [NSString stringWithString:[self.pointEnds objectForKey:@"question"]];
    
    NSMutableDictionary *editParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [editParameters setValue:@"replace" forKey:@"op"];
    
    [self.sessionManager PATCH:editQuestionURL parameters:editParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"EDIT_QUESTION successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"EDIT_QUESTION response: %@", responseJSON);
        
        
        success(responseJSON);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"EDIT_QUESTION fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"EDIT_QUESTION error:%@", errResponse);
        
        failure(error);
    }];
}

- (void)deleteLecQuestionWithParameters:(NSDictionary*)parameters
                         successHandler:(EmptyResponseBlock)success
                         failureHandler:(FailureBlock)failure{
    
    NSString *deleteQuestionURL = [NSString stringWithString:[self.pointEnds objectForKey:@"question"]];
    
    [self.sessionManager DELETE:deleteQuestionURL parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"DELETE_QUESTION successful");
        NSDictionary *responseJSON = responseObject;
        NSLog(@"DELETE_QUESTION response: %@", responseJSON);
        
        
        success();
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"DELETE_QUESTION fail with STATUS: %ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"DELETE_QUESTION error:%@", errResponse);
        
        failure(error);
    }];
}

@end
