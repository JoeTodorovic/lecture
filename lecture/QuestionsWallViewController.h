//
//  QuestionsWallViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 11/30/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QuickQuestionViewController.h"

#import "LectureQuestion.h"
#import "SocketConnectionManager.h"


@interface QuestionsWallViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *lectureTitle;
@property (strong, nonatomic) NSString *lectureUniqueid;


@property (strong, nonatomic) IBOutlet UILabel *lblLectureTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnAsk;
@property (strong, nonatomic) IBOutlet UIButton *btnLeaveLecture;
@property (strong, nonatomic) IBOutlet UITableView *tvQuestions;


- (IBAction)btnAskPressed:(id)sender;
- (IBAction)btnLeaveLecturePressed:(id)sender;

@end
