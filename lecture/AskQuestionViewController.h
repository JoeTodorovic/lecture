//
//  AskQuestionViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 12/1/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSMessage.h"
#import "TSMessageView.h"

#import "SocketConnectionManager.h"


@interface AskQuestionViewController : UIViewController <UITextViewDelegate,TSMessageViewProtocol>

@property (strong, nonatomic) IBOutlet UITextView *txtvQuestion;
@property (strong, nonatomic) IBOutlet UIButton *btnSendQuestion;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;

- (IBAction)btnSendQuestionPressed:(id)sender;
- (IBAction)btnCancelPressed:(id)sender;

@end
