//
//  ALSendQuestionViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 1/22/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSMessage.h"
#import "TSMessageView.h"

#import "QAnswerTableViewCell.h"

#import "HttpManager.h"
#import "LecturerManager.h"
#import "SocketConnectionManager.h"

#import "Lecture.h"
#import "LectureQuestion.h"

@interface ALSendQuestionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TSMessageViewProtocol>

@property (strong, nonatomic) Lecture *lecture;
@property (strong, nonatomic) LectureQuestion *question;
@property (strong, nonatomic) IBOutlet UITableView *tbvAnswers;
@property (strong, nonatomic) IBOutlet UILabel *lblQuestion;


@end
