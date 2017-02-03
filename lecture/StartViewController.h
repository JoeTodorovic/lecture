//
//  StartViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HttpManager.h"
#import "SocketConnectionManager.h"

#import "TSMessage.h"
#import "TSMessageView.h"

@interface StartViewController : UIViewController <UITextFieldDelegate, TSMessageViewProtocol>

@property (strong, nonatomic) IBOutlet UITextField *txtfLectureID;


- (IBAction)btnJoinLecturePressed:(id)sender;
- (IBAction)btnLogInPressed:(id)sender;
@end
