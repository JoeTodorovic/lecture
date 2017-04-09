//
//  RegistrationViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "LecturerManager.h"
#import "LecturerUser.h"

@interface RegistrationViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtfEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtfPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtfFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtfLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtfDescription;
@property (strong, nonatomic) IBOutlet UITextField *txtfUniversity;
@property (strong, nonatomic) IBOutlet UITextField *txtfTitle;



@property (strong, nonatomic) IBOutlet UIButton *btnRegister;

- (IBAction)btnRegisterPressed:(id)sender;
- (IBAction)btnBackPressed:(id)sender;
@end
