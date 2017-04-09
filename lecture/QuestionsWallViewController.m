//
//  QuestionsWallViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 11/30/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "QuestionsWallViewController.h"
#import "LectureQuestionTableViewCell.h"

#import "GlobalData.h"

@interface QuestionsWallViewController (){
    
    NSMutableArray *wallQuestions;
}

@end

@implementation QuestionsWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //SET Table View
    self.tvQuestions.delegate = self;
    self.tvQuestions.dataSource = self;
    self.tvQuestions.estimatedRowHeight = 44.0f;
    self.tvQuestions.rowHeight = UITableViewAutomaticDimension;
    
    //SET notifications
    [self setNotifications];
    
    //SET never go to sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //SET other
    self.lblLectureTitle.text = @"";
    wallQuestions = [[NSMutableArray alloc] init];
    
}

-(void)dealloc{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wallQuestionReceived:) name:@"listenerDisplyedQuestionNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lectureEndded:) name:@"lectureFinishedNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lectureQuestionReceived:) name:@"lecturerSentQuestionNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopListeningLectureResponse:) name:@"stopListeningLectureResponseNotification" object:nil];
    
}



#pragma mark - Selectors

-(void)wallQuestionReceived:(NSNotification *)not{
    
    if ([not.userInfo objectForKey:@"message"]) {
        wallQuestions = [[SocketConnectionManager sharedInstance].wallQuestions copy];
        [self.tvQuestions reloadData];
    }
}

-(void)lectureQuestionReceived:(NSNotification *)not{
    if ([not.userInfo objectForKey:@"message"]) {
        [self performSegueWithIdentifier:@"TestQuestionSegue" sender:[not.userInfo objectForKey:@"message"]];
    }
}

-(void)lectureEndded:(NSNotification *)not{
    NSLog(@"Lecturer ended lecture NOTIFICATION");
    [[SocketConnectionManager sharedInstance] closeConnection];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Lecture" message:@"The lecture has finished." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];

    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
}

-(void)stopListeningLectureResponse:(NSNotification *)not{
    
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        [[SocketConnectionManager sharedInstance] closeConnection];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}



#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [wallQuestions count];;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LectureQuestionTableViewCell *cellQuestion = [tableView dequeueReusableCellWithIdentifier:@"ListenerWallQuestionCell"];
    NSDictionary *messageDict = (NSDictionary *)[wallQuestions objectAtIndex:indexPath.row];
    cellQuestion.lblQuestionText.text = [messageDict valueForKey:@"question"];
    cellQuestion.lblQuestionDate.text = [messageDict valueForKey:@"date"];
    return cellQuestion;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"TestQuestionSegue"]) {
        QuickQuestionViewController *vc = segue.destinationViewController;
        vc.question = [[LectureQuestion alloc] init];
        [vc.question fromDictionary:(NSDictionary *)[sender objectForKey:@"question"]];
        NSLog(@"%@", vc.question);
    }
}


#pragma mark - button actions 

- (IBAction)btnAskPressed:(id)sender {
    
}

- (IBAction)btnLeaveLecturePressed:(id)sender {
    [[SocketConnectionManager sharedInstance] stopListenLecture];
}
@end
