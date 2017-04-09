//
//  EditLectureTableViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 2/4/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSMessage.h"
#import "TSMessageView.h"

#import "HttpManager.h"
#import "LecturerManager.h"
#import "Lecture.h"

@interface EditLectureTableViewController : UITableViewController<UITextFieldDelegate, TSMessageViewProtocol>

@property(strong, nonatomic) Lecture *lecture;

@property (strong, nonatomic) IBOutlet UITextField *txtfTitle;
@property (strong, nonatomic) IBOutlet UITextField *txtfDescription;
@property (strong, nonatomic) IBOutlet UITextField *txtfPassword;
@property (strong, nonatomic) IBOutlet UISwitch *switchPassword;

- (IBAction)switchPasswordChanged:(id)sender;

@end
