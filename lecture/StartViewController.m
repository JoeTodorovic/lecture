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

#import "GlobalData.h"

@interface StartViewController (){
    UIView *navigationBottomLine;
}

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
    
    NSDictionary *attrs1 = @{ NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:28.0]};
    NSAttributedString *attrString1 = [[NSAttributedString alloc] initWithString:@"Welcome \n" attributes:attrs1];
    
    NSDictionary *attrs2 = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:28.0] };
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:@"enter lecture ID to join lecture, \nor continue as lecturer." attributes:attrs2];

    NSMutableAttributedString *welcomeString = [[NSMutableAttributedString alloc] init];
    
    [welcomeString appendAttributedString:attrString1];
    [welcomeString appendAttributedString:attrString2];
    
    self.lblWelcome.attributedText = welcomeString;
    
    
    self.txtfLectureID.layer.borderColor = [[GlobalData sharedInstance] getColor:@"extraLightGray"].CGColor;
    self.txtfLectureID.layer.borderWidth = 0.75;
    self.txtfLectureID.textColor = [[GlobalData sharedInstance] getColor:@"lightGray"];
    self.txtfLectureID.layer.cornerRadius = 11.0;
    
    [self.btnJoin setTitleColor:[[GlobalData sharedInstance] getColor:@"red"] forState:UIControlStateNormal];
    [self.btnContinue setTitleColor:[[GlobalData sharedInstance] getColor:@"lightGray"] forState:UIControlStateNormal];
    
    
    NSDictionary *attrs3 = @{ NSForegroundColorAttributeName : [[GlobalData sharedInstance] getColor:@"red"], NSFontAttributeName : [UIFont systemFontOfSize:17.0]};
    NSAttributedString *attrString3 = [[NSAttributedString alloc] initWithString:@"Login " attributes:attrs3];
    
    NSDictionary *attrs4 = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:17.0] };
    NSAttributedString *attrString4 = [[NSAttributedString alloc] initWithString:@"to continue as lecturer" attributes:attrs4];
    
    NSMutableAttributedString *loginString = [[NSMutableAttributedString alloc] init];
    
    [loginString appendAttributedString:attrString3];
    [loginString appendAttributedString:attrString4];
    
    [self.btnContinue setAttributedTitle:loginString forState:UIControlStateNormal];
    
    
    
    navigationBottomLine = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    [navigationBottomLine setHidden:YES];
    
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

-(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        NSLog(@"GET EndPoints fail");
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
    if (![((NSNumber *)[not.userInfo valueForKey:@"userType"]) boolValue]) {
        
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
        [SocketConnectionManager sharedInstance].lecturer = NO;
        [SocketConnectionManager sharedInstance].enteringLectureId = self.txtfLectureID.text;
        [SocketConnectionManager sharedInstance].enteringLecturePassword = nil;
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


#pragma mark - Navigation Bar

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    
    return nil;
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
