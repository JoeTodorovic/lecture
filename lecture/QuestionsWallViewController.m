//
//  QuestionsWallViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 11/30/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "QuestionsWallViewController.h"
#import "LectureQuestionTableViewCell.h"
#import "ListenerQuestion.h"

#import "GlobalData.h"

@interface QuestionsWallViewController (){
    
    NSMutableArray *wallQuestions;
    UIImageView *navBarHairlineImageView;

}

@end

@implementation QuestionsWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SET Navigation Bar
    [self setTitle:@"Lecture title"];
    [self.navigationController setNavigationBarHidden:NO];
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    [navBarHairlineImageView setHidden:YES];
    if (@available(iOS 11.0, *)) {
        [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    } else {
        // Fallback on earlier versions
    }
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem *exitLecture = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"Delete"] style:UIBarButtonItemStylePlain target:self action:@selector(exitLecture)];
    [exitLecture setTintColor:[[GlobalData sharedInstance] getColor:@"red"]];
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"Delete"] style:UIBarButtonItemStylePlain target:self action:@selector(exitLecture)]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"leave" style:UIBarButtonItemStylePlain target:self action:@selector(exitLecture)]];
    [self.navigationItem.rightBarButtonItem setTintColor:[[GlobalData sharedInstance] getColor:@"red"]];
    
    //SET Table View
    self.tvQuestions.delegate = self;
    self.tvQuestions.dataSource = self;
    self.tvQuestions.estimatedRowHeight = 44.0f;
    self.tvQuestions.rowHeight = UITableViewAutomaticDimension;
    self.tvQuestions.refreshControl = [[UIRefreshControl alloc]init];
    [self.tvQuestions.refreshControl addTarget:self action:@selector(refreshListenersQuestions) forControlEvents:UIControlEventValueChanged];
    
    //SET question btn
    self.btnAsk.backgroundColor = [[GlobalData sharedInstance] getColor:@"red"];
    self.btnAsk.layer.cornerRadius = 11.0;
    [self.btnAsk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnAsk setTitle:@"ask a question" forState:UIControlStateNormal];
    
    //SET notifications
    [self setNotifications];
    
    //SET never go to sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //SET other
    self.lblLectureTitle.text = @"";
    
    wallQuestions = [[NSMutableArray alloc] init];
    
    //GET wall questions
    [SocketConnectionManager.sharedInstance getListenersQuestions];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getListenersQuestionsResponse:)
                                                 name:@"getListenersQuestionsResponseNotification"
                                               object:nil];
    
}


#pragma mark - Navigation Bar

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    
    return nil;
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

-(void)getListenersQuestionsResponse:(NSNotification *)not{
    
    [SocketConnectionManager.sharedInstance getNumberOfListeners];
    
    wallQuestions = [[SocketConnectionManager sharedInstance].wallQuestions mutableCopy];

    [self.tvQuestions reloadData];
    [self.tvQuestions.refreshControl endRefreshing];
}

-(void)refreshListenersQuestions{
    [SocketConnectionManager.sharedInstance getListenersQuestions];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [wallQuestions count];;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LectureQuestionTableViewCell *cellQuestion = [tableView dequeueReusableCellWithIdentifier:@"ListenerWallQuestionCell"];
    NSDictionary *messageDict = (NSDictionary *)[wallQuestions objectAtIndex:indexPath.row];
    
    ListenerQuestion *question = [[ListenerQuestion alloc] init];
    [question fromDictionary:[wallQuestions objectAtIndex:indexPath.row]];
    
    
    if (question.question != nil) {
        cellQuestion.lblQuestionText.text = question.question;
    }
    if (question.date != nil) {
        cellQuestion.lblQuestionDate.text = question.date;
    }
    
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

- (void)exitLecture{
    [[SocketConnectionManager sharedInstance] stopListenLecture];
}

- (IBAction)btnLeaveLecturePressed:(id)sender {
    [[SocketConnectionManager sharedInstance] stopListenLecture];
}
@end
