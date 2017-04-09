//
//  LectureViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/26/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LectureViewController.h"
#import <KVNProgress/KVNProgress.h>


@interface LectureViewController (){
    UIButton *createNewQuestion;
    NSInteger selectedQuestionIndex;
    BOOL continueLecture; // flag to continue or end lecture
}

@end

@implementation LectureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SET TSMessage
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];

    //SET Info Labeles
    self.lblLectureName.text = self.lecture.name;
    self.lblLectureDescription.text = self.lecture.lectureDescription;
    self.lblLectureId.text = [NSString stringWithFormat:@"lecture id: %@", self.lecture.uniqueId];
    
//    if (self.lecture.password) {
//        <#statements#>
//    }
    
    
    //SET navigation controller
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
    
    //SET BACK button
    if (self.newLectureFlag) {
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
        self.navigationItem.leftBarButtonItem=newBackButton;
    }
    
    //SET TableView
    self.tbvQuestions.delegate = self;
    self.tbvQuestions.dataSource = self;
    self.tbvQuestions.estimatedRowHeight = 44.0f;
    self.tbvQuestions.rowHeight = UITableViewAutomaticDimension;
    
    //GET Questions for lecture
    [self loadLecture];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNotifications];
    [self.tbvQuestions reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initSocketConnectionResponse:)
                                                 name:@"socketConnectionResponseNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(socketLoginResponse:)
                                                 name:@"loginResponseNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startLectureResponse:)
                                                 name:@"startLectureResponseNotification"
                                               object:nil];

}

#pragma mark - NavigationBar Right Button Items

-(void)setRightItemsStartEdit{
    
    UIBarButtonItem *startLectureButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(setSocket)];
    [startLectureButton setImage:[UIImage imageNamed:@"Start.png"]];
    
    UIBarButtonItem *editLectureButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editLecture)];
    [editLectureButton setImage:[UIImage imageNamed:@"Edit.png"]];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editLectureButton, startLectureButton, nil];
}

-(void)setRightItemsSocketEdit{
    
    UIBarButtonItem *setSocketButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(setSocket)];
    
    UIBarButtonItem *editLectureButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editLecture)];
    [editLectureButton setImage:[UIImage imageNamed:@"Edit.png"]];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editLectureButton, setSocketButton, nil];
}

-(void)setRightItemReloadLecture{
    
    UIBarButtonItem *setSocketButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(loadLecture)];
    
    self.navigationItem.rightBarButtonItem =setSocketButton;
}

#pragma mark - Selectors

-(void)back:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)editLecture{
    NSLog(@"edit lecture");
    [self performSegueWithIdentifier:@"LectureToEditSegue" sender:self];
}

-(void)setSocket{
    NSLog(@"Set Socket");
    if (![SocketConnectionManager sharedInstance].connected) {
        [KVNProgress showWithStatus:@"Connecting to Socket..."];
        [SocketConnectionManager sharedInstance].lecturer = YES;
        [[SocketConnectionManager sharedInstance] initSocketConnection];
    }
    else{
        if (![SocketConnectionManager sharedInstance].isLoggedIn) {
            [KVNProgress showWithStatus:@"Logging in to Socket..."];
            [[SocketConnectionManager sharedInstance] loginWithId:[LecturerManager sharedInstance].userProfile.userId];
        }
    }
    
}

-(void)initSocketConnectionResponse:(NSNotification *)not{
    NSLog(@"initSocketConnection NOTIFICATION Response");
    
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        [KVNProgress updateStatus:@"Loging in to Socket..."];
        [[SocketConnectionManager sharedInstance] loginWithId:[LecturerManager sharedInstance].userProfile.userId];
    }
    else{
        if (![LecturerManager sharedInstance].loginToLectureFlag) {
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:NSLocalizedString(self.lecture.name, nil)
                                            subtitle:NSLocalizedString(@"Failed to connect to socket.", nil)
                                                type:TSMessageNotificationTypeMessage];
            }];
        }
        else{
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:NSLocalizedString(self.lecture.name, nil)
                                            subtitle:NSLocalizedString(@"Failed to connect to socket. Tap redo to try to perform action again.", nil)
                                                type:TSMessageNotificationTypeMessage];
            }];
//            UIBarButtonItem *setSocketButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(setSocket)];
//            self.navigationItem.rightBarButtonItem =setSocketButton;
            
            [self setRightItemsSocketEdit];
        }
    }
}

-(void)socketLoginResponse:(NSNotification *)not{
    
    NSLog(@"socketLogin NOTIFICATION Response");
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        
        if (![LecturerManager sharedInstance].loginToLectureFlag) {
            [KVNProgress updateStatus:@"Starting Lecture..."];
            [[SocketConnectionManager sharedInstance] startLectureWithId:self.lecture.uniqueId andPassword:nil];
        }
        else{
            if (continueLecture) {
                NSLog(@"Continue to lecture");
                [KVNProgress dismiss];
                ALViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ActiveLectureViewSID"];
                vc.lecture = self.lecture;
                [SocketConnectionManager sharedInstance].wallQuestions = [[NSMutableArray alloc] init];
                [SocketConnectionManager sharedInstance].activeLectureId = [NSString stringWithString:self.lecture.uniqueId];
                [self.navigationController pushViewController:vc animated:NO];
                
//                [self setRightItemsSocketEdit];
            }
            else{
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(endLectureResponse:)
                                                             name:@"endLectureResponseNotification"
                                                           object:nil];
                
                [[SocketConnectionManager sharedInstance] endLectureWithId:self.lecture.uniqueId];
            }
        }
    }
    else
    {
        if (![LecturerManager sharedInstance].loginToLectureFlag) {
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:NSLocalizedString(self.lecture.name, nil)
                                            subtitle:NSLocalizedString(@"Failed to Login to socket.", nil)
                                                type:TSMessageNotificationTypeMessage];
            }];
        }
        else{
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:NSLocalizedString(self.lecture.name, nil)
                                            subtitle:NSLocalizedString(@"Failed to Login to socket. Tap redo to try to perform selected action again.", nil)
                                                type:TSMessageNotificationTypeMessage];
            }];
//            UIBarButtonItem *setSocketButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(setSocket)];
//            
//            self.navigationItem.rightBarButtonItem =setSocketButton;
            
            [self setRightItemsSocketEdit];
        }
    }
}

-(void)startLectureResponse:(NSNotification *)not{
    
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        [self startLecture];
    }
    else{
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:NSLocalizedString(self.lecture.name, nil)
                                        subtitle:NSLocalizedString(@"Failed to start lecture. Tap redo to try to perform selected action again.", nil)
                                            type:TSMessageNotificationTypeMessage];
        }];
    };
}


-(void)endLectureResponse:(NSNotification *)not{
    
    NSLog(@"endLecture NOTIFICATION Response");
    
    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
        NSLog(@"LECTURE End successfull");
        [[SocketConnectionManager sharedInstance] closeConnection];
        [LecturerManager sharedInstance].loginToLectureFlag = NO;
        [LecturerManager sharedInstance].runningLectureUniqueId = nil;
        
//        UIBarButtonItem *startLectureButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(setSocket)];
//        [startLectureButton setImage:[UIImage imageNamed:@"Start.png"]];
//        self.navigationItem.rightBarButtonItem =startLectureButton;
        
        [self setRightItemsStartEdit];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"endLectureResponseNotification" object:nil];
        [KVNProgress showSuccessWithStatus:@"Lecture ended."];
    }
    else{
        NSLog(@"END LECTURE failed");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"endLectureResponseNotification" object:nil];
        [KVNProgress showErrorWithStatus:@"Fail to end lecture."];
    }
}

-(void)loadLecture{
    
    NSLog(@"Load Lecture");
    
    [KVNProgress show];
    
    [[HttpManager sharedInstance] getLectureWithId:self.lecture.lectureId successHandler:^(NSDictionary *lectureInfo) {
        [self.lecture fromDictionary:lectureInfo];
        [self.tbvQuestions reloadData];
        
        
        self.lblLectureName.text = self.lecture.name;
        self.lblLectureDescription.text = self.lecture.lectureDescription;
        
        
        if (![LecturerManager sharedInstance].loginToLectureFlag) {
            
//            UIBarButtonItem *startLectureButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(setSocket)];
//            [startLectureButton setImage:[UIImage imageNamed:@"Start.png"]];
//            
//            self.navigationItem.rightBarButtonItem =startLectureButton;
            
            [self setRightItemsStartEdit];
            
            [KVNProgress dismiss];
        }
        else{
            NSLog(@"Running lecture");
            [KVNProgress dismiss];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"Lecture %@ is already running would you like to continue this lecture or to end it?",self.lecture.name] preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"End" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                continueLecture = NO;
                [self setSocket];
                [alertController dismissViewControllerAnimated:YES completion:^{
                    [KVNProgress show];
                }];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                continueLecture = YES;
                [self setSocket];
                [alertController dismissViewControllerAnimated:YES completion:^{
                    [KVNProgress show];
                }];
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:alertController animated:YES completion:nil];
            });
            
            
        }
        
    } failureHandler:^(NSError *error) {
        NSLog(@"Failed to Load Lecture");
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:NSLocalizedString(self.lecture.name, nil)
                                        subtitle:NSLocalizedString(@"Failed to load lecture data. Tap redo to try again.", nil)
                                            type:TSMessageNotificationTypeMessage];
        }];
        
//        UIBarButtonItem *reloadLectureButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(loadLecture)];
//
//        self.navigationItem.rightBarButtonItem =reloadLectureButton;
        [self setRightItemReloadLecture];
    }];

}

-(void)startLecture{
    NSLog(@"LETURE Start successfull");
    [KVNProgress dismiss];
    [self performSegueWithIdentifier:@"StartLectureSegue" sender:self];
}

-(void)createNewQuestion:(UIButton *)sender {
    [self performSegueWithIdentifier:@"LectureToQuestionSegue" sender:sender];
}

#pragma mark - Alert View

-(void)showAlertWithMessage:(NSString *)message{
    
    
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.lecture.questions count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LectureQuestionTableViewCell  *cellQuestion = [tableView dequeueReusableCellWithIdentifier:@"LectureQuestionCell"];
    
    LectureQuestion *question = [self.lecture.questions objectAtIndex:indexPath.row];
    
    cellQuestion.lblQuestionText.text = question.question;
    
    return cellQuestion;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedQuestionIndex = indexPath.row;
    [self performSegueWithIdentifier:@"LectureToQuestionSegue" sender:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 44.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width-40.0, 44.0)];
    footer.backgroundColor = [UIColor whiteColor];
    
    
    createNewQuestion = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [createNewQuestion addTarget:self
                          action:@selector(createNewQuestion:)
                forControlEvents:UIControlEventTouchUpInside];
    createNewQuestion.frame = CGRectMake(8.0, 11.0, 22.0, 22.0);
    
    UILabel *questionLbl = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 11.0, 201.0, 21.0)];
    [questionLbl setText:@"Add Question"];
    [questionLbl setBackgroundColor:[UIColor whiteColor]];
    [questionLbl setTextColor:[UIColor blackColor]];
    
    
    [footer addSubview:questionLbl];
    [footer addSubview:createNewQuestion];
    
    return footer;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        [[HttpManager sharedInstance] removeQuestionWithId:((LectureQuestion*)[self.lecture.questions objectAtIndex:indexPath.row]).questionId fromLecture:self.lecture.lectureId successHandler:^{
            
            [self.lecture.questions removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tbvQuestions reloadData];
            
        } failureHandler:^(NSError *error) {
            
        }];
    }
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"LectureToQuestionSegue"]){
        QuestionViewController *vc = segue.destinationViewController;
        vc.lecture = self.lecture;
        
        if (sender == createNewQuestion){
            vc.editFlag = YES;
            vc.newQuestionFlag = YES;
        }
        else{
            vc.editFlag = NO;
            vc.newQuestionFlag = NO;
            vc.question = [self.lecture.questions objectAtIndex:selectedQuestionIndex];
        }
        
    }
    else{
        if ([segue.identifier   isEqualToString:@"StartLectureSegue"]) {
            ALViewController *vc = segue.destinationViewController;
            vc.lecture = self.lecture;
        }
    }
    
    if ([segue.identifier   isEqualToString:@"LectureToEditSegue"]) {
        EditLectureTableViewController *vc = segue.destinationViewController;
        vc.lecture = self.lecture;
    }
}


- (IBAction)closeC:(id)sender {
    
    if ([SocketConnectionManager sharedInstance].connected) {
        [[SocketConnectionManager sharedInstance] closeConnection];
    }
}
@end
