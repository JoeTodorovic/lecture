//
//  AskQuestionViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/1/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "AskQuestionViewController.h"
#import <KVNProgress/KVNProgress.h>


@interface AskQuestionViewController ()

@end

@implementation AskQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SET txtView
    self.txtvQuestion.delegate = self;
    [self.txtvQuestion becomeFirstResponder];
    
    //SET TSMessage
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
}

-(void)setNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendQuestionResponse:) name:@"sendListenerQuestionResponseNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Selectors

-(void)sendQuestionResponse:(NSNotification *)not{
    
    if ([(NSNumber *)[not.userInfo objectForKey:@"status"] boolValue]) {
        [KVNProgress dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Fail to send question, please try again.", nil)
                                        subtitle:nil
                                            type:TSMessageNotificationTypeMessage];
            }];
    }
}

#pragma mark - TextView

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.txtvQuestion resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextField *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSendQuestionPressed:(id)sender {
    
    [KVNProgress showWithStatus:@"Sending question..."];
    [self.txtvQuestion resignFirstResponder];
    [[SocketConnectionManager sharedInstance] sendQuestion:self.txtvQuestion.text toLecture:[SocketConnectionManager sharedInstance].activeLectureId];
}

- (IBAction)btnCancelPressed:(id)sender {
    [self.txtvQuestion resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
