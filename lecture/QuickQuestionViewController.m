//
//  QuickQuestionViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/8/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "QuickQuestionViewController.h"
#import <KVNProgress/KVNProgress.h>

#import "QAnswerTableViewCell.h"

@interface QuickQuestionViewController (){
    
    NSTimer *timer;
    NSTimer *changePositionTimer;
    
    int time;

    NSNumber *selectedAnswer;
    BOOL answerSentFlag;
    BOOL answerSelectedFlag;
}

@end

@implementation QuickQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SET TSMessage
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    //SET table view
    self.tbvAnswers.dataSource = self;
    self.tbvAnswers.delegate = self;
    
    //SET labels
    self.lblQuestion.text = self.question.question;
//    self.lblQuestion.text = @"Nesto da vidimo kako izgleda skldjlksda.";
    
    //    self.lblTimer.text = [self.question.time stringValue];

    //SET buttons
    self.btnSendAnswer.hidden = YES;    
    self.btnClose.hidden = YES;
    
    answerSentFlag = NO;
    answerSelectedFlag = NO;
    selectedAnswer = [NSNumber numberWithInt:0];
    time = self.question.time.intValue;
    
    [self setNotifications];
    
    time = 10;
    [self StartTimer];
//    self.question = [[LectureQuestion alloc] init];
//    self.question.correctIndex = [NSNumber numberWithInteger:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAnswerResponse:) name:@"sendAnswerResponseNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lectureEndded:) name:@"lectureFinishedNotification" object:nil];
}

#pragma mark - Timer

-(void) StartTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}

//Event called every time the NSTimer ticks.
- (void)timerTick:(NSTimer *)timer{
    time--;

    //Display on your label
    self.lblTimer.text= [NSString stringWithFormat:@"%d", time];
    
    if (time == 0)
        [self StopTimer];

}

//Call this to stop the timer event(could use as a 'Pause' or 'Reset')
- (void) StopTimer{
    [timer invalidate];
    self.btnSendAnswer.hidden = YES;
    self.btnClose.hidden = NO;
    self.tbvAnswers.userInteractionEnabled = NO;
    if (!answerSentFlag) {
        if (![SocketConnectionManager sharedInstance].isWaitingResponse) {
            
        }
        answerSelectedFlag = NO;
        [self.tbvAnswers reloadData];
    }
    else{
        //TO DO
    }
}


#pragma mark - Selectors

-(void)sendAnswerResponse:(NSNotification *)not{
    
    if ([(NSNumber *)[not.userInfo valueForKey:@"status"] boolValue]) {
        [KVNProgress dismiss];
        self.btnClose.hidden = NO;
        self.btnSendAnswer.hidden = YES;
        self.lblTimer.hidden = YES;
        
        //UPDATE selected and correct cell
        answerSentFlag = YES;
        [self.tbvAnswers reloadData];
    }
    else{
        self.btnSendAnswer.userInteractionEnabled = YES;
        self.tbvAnswers.userInteractionEnabled = YES;
        [KVNProgress dismissWithCompletion:^{
                    [TSMessage showNotificationWithTitle:@"Answer not sent, please try again." type:TSMessageNotificationTypeMessage];
        }];
    }
}

-(void)lectureEndded:(NSNotification *)not{
    NSLog(@"Lecturer ended lecture NOTIFICATION");
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Lecture" message:@"The lecture has finished." preferredStyle:UIAlertControllerStyleAlert];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        
//        [alertController dismissViewControllerAnimated:YES completion:^{
//            [self dismissViewControllerAnimated:YES completion:nil];
//            }
//         ];
//    }]];
//    
//    dispatch_async(dispatch_get_main_queue(), ^ {
//        [self presentViewController:alertController animated:YES completion:nil];
//    });
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.question.answers count];
//    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QAnswerTableViewCell  *cellAnswer = [tableView dequeueReusableCellWithIdentifier:@"QuickQAnswerCell"];
    cellAnswer.lblAnswerMark.text = [NSString stringWithFormat:@"%ld)", (long)(indexPath.row)+1];
    cellAnswer.lblAnswer.text = (NSString *)[self.question.answers objectAtIndex:indexPath.row];

    [cellAnswer.lblAnswerMark setTextColor:[UIColor blackColor]];
    [cellAnswer.lblAnswer setTextColor:[UIColor blackColor]];
    
    
    //marking selected ansewer
    if (answerSelectedFlag && selectedAnswer.integerValue == indexPath.row) {

        cellAnswer.lblAnswerMark.layer.borderColor = [UIColor greenColor].CGColor;
        cellAnswer.lblAnswerMark.layer.borderWidth = 1;
        cellAnswer.lblAnswerMark.layer.cornerRadius = 30.0/2;
    }
    else{
        cellAnswer.lblAnswerMark.layer.borderColor = [UIColor whiteColor].CGColor;
        cellAnswer.lblAnswerMark.layer.borderWidth = 0;
        cellAnswer.lblAnswerMark.layer.cornerRadius = 0;
    }

    //showing correct answer after sending answer or time up
    if ((time==0 || answerSentFlag) && indexPath.row == self.question.correctIndex.integerValue
        ) {
        cellAnswer.layer.borderWidth = 1;
        cellAnswer.layer.borderColor = [UIColor greenColor].CGColor;
    }
    else{
        cellAnswer.layer.borderWidth = 0;
        cellAnswer.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    //if sent answer is wrong marking it red
    if (answerSentFlag && selectedAnswer.integerValue != self.question.correctIndex.integerValue && selectedAnswer.integerValue == indexPath.row) {
                cellAnswer.lblAnswerMark.layer.borderColor = [UIColor redColor].CGColor;
    }
    
    return cellAnswer;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.btnSendAnswer.userInteractionEnabled = YES;
    self.btnSendAnswer.hidden = NO;

    NSLog(@"%ld", (long)indexPath.row);
    answerSelectedFlag = YES;
    selectedAnswer = [NSNumber numberWithInteger:indexPath.row];
    [self.tbvAnswers reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSendAnswerPressed:(id)sender {
    [KVNProgress showWithStatus:@"Sending answer"];
    [[SocketConnectionManager sharedInstance] sendAnswer:selectedAnswer toQuestion:self.question.questionId];
    self.tbvAnswers.userInteractionEnabled = NO;
    self.btnSendAnswer.userInteractionEnabled = NO;
    [timer invalidate];
}

- (IBAction)btnClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
