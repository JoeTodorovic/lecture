//
//  QuestionViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 12/27/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSMessage.h"
#import "TSMessageView.h"

#import "HttpManager.h"
#import "LecturerManager.h"

#import "Lecture.h"
#import "LectureQuestion.h"

#import "QAnswerTableViewCell.h"
#import "EditQAnswerTableViewCell.h"

@interface QuestionViewController : UIViewController<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, TSMessageViewProtocol>

@property (strong, nonatomic) Lecture *lecture;
@property (strong, nonatomic) LectureQuestion *question;

@property BOOL editFlag;
@property BOOL newQuestionFlag;

@property (strong, nonatomic) IBOutlet UITextView *txtvQuestion;

@property (strong, nonatomic) IBOutlet UITableView *tbvAnswers;

@end
