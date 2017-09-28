//
//  ALViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 1/17/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BadgeSegmentedControl.h"

#import "LectureWallTableViewCell.h"
#import "ALQuestionTableViewCell.h"
#import "ALSendQuestionViewController.h"

#import "Lecture.h"
#import "LectureQuestion.h"
#import "ListenerQuestion.h"
#import "LecturerManager.h"

#import "HttpManager.h"
#import "SocketConnectionManager.h"

@interface ALViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIToolbarDelegate>

@property (strong, nonatomic) Lecture *lecture;

@property bool continuedLectureFlag;

@property (strong, nonatomic) IBOutlet BadgeSegmentedControl *scWallQuestions;

@property (strong, nonatomic) IBOutlet UITableView *tbvAL;

@property (strong, nonatomic) IBOutlet UIToolbar *tbSC;

@property (strong, nonatomic) IBOutlet UIView *viewBottomStatus;
@property (strong, nonatomic) IBOutlet UILabel *lblNumberOfListeners;
@property (strong, nonatomic) IBOutlet UILabel *lblLectureID;


- (IBAction)scChanged:(id)sender;

@end
