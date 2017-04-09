//
//  LectureViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSMessage.h"
#import "TSMessageView.h"

#import "QuestionViewController.h"
#import "ALViewController.h"
#import "EditLectureTableViewController.h"

#import "LectureQuestionTableViewCell.h"

#import "Lecture.h"
#import "LectureQuestion.h"

#import "LecturerManager.h"
#import "HttpManager.h"
#import "SocketConnectionManager.h"

@interface LectureViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,TSMessageViewProtocol>

@property(strong, nonatomic) Lecture *lecture;
@property bool newLectureFlag;

@property (strong, nonatomic) IBOutlet UILabel *lblLectureName;
@property (strong, nonatomic) IBOutlet UILabel *lblLectureDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblLectureId;
@property (strong, nonatomic) IBOutlet UILabel *lblLecturePassword;


@property (strong, nonatomic) IBOutlet UITableView *tbvQuestions;

- (IBAction)closeC:(id)sender;

@end
