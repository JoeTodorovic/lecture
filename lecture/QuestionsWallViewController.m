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
    
    //SET Ask Button
    self.btnAsk.layer.cornerRadius = 49.0/2.0f;
    self.btnAsk.layer.borderColor = [[GlobalData sharedInstance] getColor:@"blue"].CGColor;
    self.btnAsk.layer.borderWidth = 1.0f;
    
    //SET notifications
    [self setNotifications];
    
    //SET other
    
    self.lblLectureTitle.text = @"";
    wallQuestions = [[NSMutableArray alloc] init];
    
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
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)stopListeningLectureResponse:(NSNotification *)not{
    
    if ([((NSNumber *)[not.userInfo valueForKey:@"ok"]) boolValue]) {
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
    
    cellQuestion.lblQuestionText.text = (NSString *)[wallQuestions objectAtIndex:indexPath.row];
    
    return cellQuestion;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"TestQuestionSegue"]) {
        QuickQuestionViewController *vc = segue.destinationViewController;
        vc.question = [[LectureQuestion alloc] init];
        [vc.question fromDictionary:(NSDictionary *)sender];
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
