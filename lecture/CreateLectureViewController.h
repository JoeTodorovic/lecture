//
//  CreateLectureViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LectureViewController.h"

#import "LecturerManager.h"
#import "HttpManager.h"
#import "Lecture.h"

@interface CreateLectureViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) LectureViewController * LectureVC;

@property (strong, nonatomic) IBOutlet UITextField *txtfName;
@property (strong, nonatomic) IBOutlet UITextView *txtvDescription;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnCreate;


- (IBAction)btnCancel:(id)sender;
- (IBAction)btnCreateLecturePressed:(id)sender;

@end
