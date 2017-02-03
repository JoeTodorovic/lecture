//
//  QuickQuestionViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 12/8/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSMessage.h"
#import "TSMessageView.h"

#import "LectureQuestion.h"

#import "SocketConnectionManager.h"

@interface QuickQuestionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,TSMessageViewProtocol>

@property (strong, nonatomic) LectureQuestion *question;

@property (strong, nonatomic) IBOutlet UILabel *lblQuestion;
@property (strong, nonatomic) IBOutlet UILabel *lblTimer;
@property (strong, nonatomic) IBOutlet UIButton *btnSendAnswer;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UITableView *tbvAnswers;

- (IBAction)btnSendAnswerPressed:(id)sender;
- (IBAction)btnClosePressed:(id)sender;

@end
