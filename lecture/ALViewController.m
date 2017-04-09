//
//  ALViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 1/17/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import "ALViewController.h"

@interface ALViewController (){
    NSMutableArray *wallQuestions;
    NSInteger selectedQuestionIndex;
    NSInteger displayQuestionIndex;
    UIImageView *navBarHairlineImageView;
    int newUnseenQuestionsCouter;
    
    UIView *badgeView;
    UILabel *badgeLabel;
}

@end

@implementation ALViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tbvAL.delegate = self;
    self.tbvAL.dataSource = self;
    self.tbvAL.estimatedRowHeight = 74.0f;
    self.tbvAL.rowHeight = UITableViewAutomaticDimension;
    self.tbvAL.separatorColor = [UIColor whiteColor];
    
    wallQuestions = [[NSMutableArray alloc] init];
    
    [self setNotifications];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    //Segment control
    newUnseenQuestionsCouter = 0;
    self.tbSC.delegate = self;
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    badgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15.0, 15.0)];
    badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15.0, 15.0)];
    

    //Navigation Bar
    [self.navigationItem setTitle:self.lecture.name];
    //end lecture Button
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *endLectureButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(endLecture)];
    self.navigationItem.rightBarButtonItem =endLectureButton;
    
    //SET Lecture question results
    [self.lecture initQuestionsResults];
    
    //Update listeners number
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(numberOfListeners) userInfo:nil repeats:YES];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    navBarHairlineImageView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[SocketConnectionManager sharedInstance] closeConnection];
    
    navBarHairlineImageView.hidden = NO;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endLectureResponse:)
                                                 name:@"endLectureResponseNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayListenerQuestionResponse:)
                                                 name:@"displayListenerQuestionResponseNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenerSentQuestion:)
                                                 name:@"listenerSentQuestionNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(numberOfListenersResponse:)
                                                 name:@"getNumberOfListenersResponseNotification"
                                               object:nil];
    
}



#pragma mark - Selectors

-(void)endLecture{
    [[SocketConnectionManager sharedInstance] endLectureWithId:self.lecture.uniqueId];
    
}

-(void)displayListenerQuestion:(UIButton *)sender{
    [[SocketConnectionManager sharedInstance] sendListenerQuestion:(NSString *)[wallQuestions objectAtIndex:sender.tag] toLecture:self.lecture.uniqueId];
}

-(void)numberOfListeners{
    [SocketConnectionManager.sharedInstance getNumberOfListeners];
}

-(void)listenerSentQuestion:(NSNotification *)not{
    
    wallQuestions = [[SocketConnectionManager sharedInstance].wallQuestions mutableCopy];
    
    if (self.scWallQuestions.selectedSegmentIndex == 1) {
        newUnseenQuestionsCouter++;
        [self setBadge:[NSString stringWithFormat:@"%d",newUnseenQuestionsCouter] forSegmentAtIndex:0];

    }
    else{
        [self.tbvAL reloadData];
//        [self scrollToBottom];
    }
}

-(void)endLectureResponse:(NSNotification *)not{
    
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        NSLog(@"LECTURE End successfull");
        [[SocketConnectionManager sharedInstance] closeConnection];
        [LecturerManager sharedInstance].loginToLectureFlag = NO;
        [LecturerManager sharedInstance].runningLectureUniqueId = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"END LECTURE failed");
        [self showAlertWithMessage:(NSString *)[not.userInfo valueForKey:@"message"]];
    }
}


-(void)displayListenerQuestionResponse:(NSNotification *)not{
 
    if ([[not.userInfo valueForKey:@"status"] boolValue]) {
        NSLog(@"DisplayListenerQuestion successfully");
    }
    else{
        NSLog(@"DisplayListenerQuestion fail");
    }
}


-(void)numberOfListenersResponse:(NSNotification *)not{
    
    if ([[not.userInfo valueForKey:@"status"] boolValue]) {
        NSLog(@"GetNumberOfListeners successfully");
        
        NSNumber *numOfListenres = (NSNumber *)[not.userInfo valueForKey:@"numOfListeners"];
        self.lblNumberOfListeners.text = [numOfListenres stringValue];
    }
    else{
        NSLog(@"GetNumberOfListeners fail");
    }
}



#pragma mark - Alert View

-(void)showAlertWithMessage:(NSString *)message{
    
    
}

#pragma mark - SegmentController

- (IBAction)scChanged:(id)sender {
    
    if (((UISegmentedControl *)sender).selectedSegmentIndex == 0) {
        newUnseenQuestionsCouter = 0;
        [self setBadge:@"0" forSegmentAtIndex:0];
        [self.tbvAL reloadData];
//        [self scrollToBottom];
    }
    else{
        [self.tbvAL reloadData];
    }
    
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


- (void)setBadge:(NSString *)badge
forSegmentAtIndex:(NSUInteger)index
{
    
    // If empty we finished
    if (![badge isEqualToString:@"0"] && (badge != nil)){
        // Configure
        
        [badgeView setBackgroundColor:[UIColor redColor]];
        badgeView.layer.cornerRadius = 15.0f/2;
        badgeView.clipsToBounds = YES;
    
        
        [badgeView addSubview:badgeLabel];
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.text = badge;
        badgeLabel.textColor = [UIColor whiteColor];
        [badgeLabel setFont:[UIFont systemFontOfSize:11]];
        
        
        // Place it
        CGRect frame = badgeView.frame;
        frame.origin = self.scWallQuestions.frame.origin;
        frame.origin.x += (self.scWallQuestions.frame.size.width / self.scWallQuestions.numberOfSegments) * (index + 1);          // Just outside
        frame.origin.x -= badgeView.frame.size.width + 2.0;                                       // Pull it in
        frame.origin.x -= MAX(0.0,
                              CGRectGetMaxX(frame) - CGRectGetMaxX(self.scWallQuestions.superview.bounds)); // Not too much to the right!
        frame.origin.y -= 10.0;                                                             // Just on top
        frame.origin.y = MAX(2.0,
                             frame.origin.y);                                               // Not too high!
        badgeView.frame = frame;
        
        [self.scWallQuestions.superview addSubview:badgeView];
    }
    else{
        [badgeView removeFromSuperview];
    }
    
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.scWallQuestions.selectedSegmentIndex == 0)
        return [wallQuestions count];
    else
        return [self.lecture.questions count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.scWallQuestions.selectedSegmentIndex == 0) {
        LectureWallTableViewCell  *cellW = [tableView dequeueReusableCellWithIdentifier:@"LecturerWallCell"];
        
        NSDictionary *questionDict = (NSDictionary *)[wallQuestions objectAtIndex:indexPath.row];
        cellW.lblWallQuestion.text = (NSString *)[questionDict valueForKey:@"question"];
        cellW.lblTime.text = (NSString *)[questionDict valueForKey:@"date"];
        cellW.btnDisplay.tag = indexPath.row;
        [cellW.btnDisplay addTarget:self action:@selector(displayListenerQuestion:) forControlEvents:UIControlEventTouchDown];
        return cellW;
    
    }
    else{
        
        LectureQuestion *question = [self.lecture.questions objectAtIndex:indexPath.row];
        ALQuestionTableViewCell  *cellQ = [tableView dequeueReusableCellWithIdentifier:@"ALQuestionsCell"];
        
        cellQ.userInteractionEnabled = YES;
        cellQ.lblQuestion.text = question.question;
        
        return  cellQ;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.scWallQuestions.selectedSegmentIndex == 1) {
        selectedQuestionIndex = indexPath.row;
        [self performSegueWithIdentifier:@"ALtoQuestionSegue" sender:nil];
    }
}

-(void)scrollToBottom{
    NSInteger index = [wallQuestions count] - 1;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tbvAL scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ALtoQuestionSegue"]){
        ALSendQuestionViewController *vc = segue.destinationViewController;
        vc.lecture = self.lecture;
        vc.question = (LectureQuestion *)[self.lecture.questions objectAtIndex:selectedQuestionIndex];
    }
}


@end
