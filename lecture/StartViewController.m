//
//  StartViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "StartViewController.h"

#import "QuestionsWallViewController.h"

#import <KVNProgress/KVNProgress.h>


@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    KVNProgressConfiguration *configuration = [KVNProgressConfiguration defaultConfiguration];
    [configuration setFullScreen:YES];
    [KVNProgress setConfiguration:configuration];
    
    [self getEndPoints];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getEndPoints{

    [KVNProgress show];

    [[HttpManager sharedInstance] getEndPointsWithSuccessHandler:^(NSDictionary *myInfo) {
        NSLog(@"GET EndPoints success");
        [KVNProgress dismiss];
        
    } failureHandler:^(NSError *error) {
        NSLog(@"GET EndPoints success");
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Something failed", nil)
                                        subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check that!", nil)
                                            type:TSMessageNotificationTypeMessage];
            //            self.view.userInteractionEnabled = NO;
        }];
        
    }];
}

-(void)setNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initSocketConnectionResponse:)
                                                 name:@"socketConnectionResponseNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(socketLoginResponse:)
                                                 name:@"loginResponseNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenLectureResponse:)
                                                 name:@"listenLectureResponseNotification"
                                               object:nil];
}


#pragma mark - Selectors

-(void)setSocket{
    
    NSLog(@"Set Socket");
    if (![SocketConnectionManager sharedInstance].connected) {
        [KVNProgress showWithStatus:@"Connecting to Socket..."];
        [[SocketConnectionManager sharedInstance] initSocketConnection];
    }
    else{
        if (![SocketConnectionManager sharedInstance].isLoggedIn) {
            [KVNProgress showWithStatus:@"Logging in to Socket..."];
            [[SocketConnectionManager sharedInstance] loginWithId:[LecturerManager sharedInstance].userProfile.userId];
        }
        else{
            [KVNProgress showWithStatus:@"Entering Lecture..."];
            [[SocketConnectionManager sharedInstance] listenLectureWithId:self.txtfLectureID.text andPassword:nil];
        }
    }
    
}

-(void)initSocketConnectionResponse:(NSNotification *)not{
    NSLog(@"initSocketConnection NOTIFICATION Response");
    
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        [KVNProgress updateStatus:@"Logging in to Socket..."];
        [[SocketConnectionManager sharedInstance] loginListener];
    }
    else{
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:NSLocalizedString(@"Join lecture", nil)
                                            subtitle:NSLocalizedString(@"Failed to connect to socket.", nil)
                                                type:TSMessageNotificationTypeMessage];
            }];
    }
}

-(void)socketLoginResponse:(NSNotification *)not{
    
    NSLog(@"socketLogin NOTIFICATION Response");
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        
        [KVNProgress updateStatus:@"Entering Lecture..."];
        
        [[SocketConnectionManager sharedInstance] listenLectureWithId:self.txtfLectureID.text andPassword:nil];
    }
    else{
        
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Join lecture", nil)
                                        subtitle:NSLocalizedString(@"Failed to Login to socket.", nil)
                                            type:TSMessageNotificationTypeMessage];
        }];

    }
}

-(void)listenLectureResponse:(NSNotification *)not{
    
    NSLog(@"enterLecture NOTIFICATION Response");
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        [KVNProgress dismiss];
        [self performSegueWithIdentifier:@"StartToLectureSegue" sender:self];
    }
    else{
        NSLog(@"Failed to join Lecture");
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Join lecture", nil)
                                        subtitle:@"Failed to join lecture."
                                            type:TSMessageNotificationTypeMessage];
        }];
    };
}


- (IBAction)btnJoinLecturePressed:(id)sender{
    
    if ((self.txtfLectureID.text != nil) && (![self.txtfLectureID.text isEqualToString:@""])) {
        NSLog(@"Join lecture pressed");
        [self setSocket];
    }
    else{
        [TSMessage showNotificationWithTitle:@"Join lecture"
                                    subtitle:@"Please enter lecture id."
                                        type:TSMessageNotificationTypeMessage];
    }
}

- (IBAction)btnLogInPressed:(id)sender{
    [self performSegueWithIdentifier:@"StartToLogInSegue" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"StartToLectureSegue"]){
        QuestionsWallViewController *vc = segue.destinationViewController;
        vc.lectureUniqueid = self.txtfLectureID.text;
    }
}


@end
