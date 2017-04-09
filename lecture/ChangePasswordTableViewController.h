//
//  ChangePasswordTableViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 2/16/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LecturerUser.h"
#import "LecturerManager.h"
#import "HttpManager.h"

@interface ChangePasswordTableViewController : UITableViewController<UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITextField *txtfCurrentPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtfNewPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSecureCP;
@property (strong, nonatomic) IBOutlet UIButton *btnSecureNP;

- (IBAction)btnSecureCPPressed:(id)sender;
- (IBAction)btnSecureNPPressed:(id)sender;

@end
