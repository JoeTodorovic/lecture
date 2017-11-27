//
//  LogInViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HttpManager.h"
#import "SocketConnectionManager.h"
#import "LecturerManager.h"

#import "LecturerUser.h"
#import "Lecture.h"

#import "TSMessageView.h"

@interface LogInViewController : UIViewController<UITextFieldDelegate, TSMessageViewProtocol>

@property (strong, nonatomic) IBOutlet UITextField *txtfEmailUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtfPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogIn;
@property (strong, nonatomic) IBOutlet UIButton *btnRegistration;

- (IBAction)btnLogInPressed:(id)sender;

@end
