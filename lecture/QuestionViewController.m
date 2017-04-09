//
//  QuestionViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/27/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "QuestionViewController.h"
#import <KVNProgress/KVNProgress.h>


@interface QuestionViewController (){
    UITextView *currentTextView;
    NSMutableArray *answers;
    NSNumber *correctIndex;
    
    BOOL questionCreatedFlag;
    BOOL questionConnectedToLectureFlag;
    
}

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SET TableView
    self.tbvAnswers.dataSource = self;
    self.tbvAnswers.delegate = self;
    self.tbvAnswers.estimatedRowHeight = 53.0f;
    self.tbvAnswers.rowHeight = UITableViewAutomaticDimension;
    self.tbvAnswers.allowsMultipleSelectionDuringEditing = NO;
    
    //SET txtview
    self.txtvQuestion.delegate = self;
    if (!self.editFlag) {
        self.txtvQuestion.text = self.question.question;
    }
    [self setQuestionTextView];
    
    //SET Navigation item
    [self.navigationController setNavigationBarHidden:NO];
    [self setBarButonItems];
    
    //SET TSMessage
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    //SET variables
    if (self.question != nil)
        correctIndex = self.question.correctIndex;
    else
        correctIndex = [NSNumber numberWithInt:0];
    
    answers = [[NSMutableArray alloc] initWithArray:self.question.answers];
    
    //for new question only
    questionCreatedFlag = NO;
    questionConnectedToLectureFlag = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - NavigationItems

-(void)setBarButonItems{
    
    if (self.editFlag) {

        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveEditing)];
        
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)];
    }
    else{
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEditing)];
        
        self.navigationItem.leftBarButtonItem=nil;
    }
}

-(void)saveEditing{
    
    [currentTextView resignFirstResponder];
    [self.txtvQuestion resignFirstResponder];
    
    if ([answers count]>0) {
        
        int d=2;
        
        NSMutableDictionary *newQuestionParameteres = [[NSMutableDictionary alloc] init];
        
        [newQuestionParameteres setValue:self.txtvQuestion.text forKey:@"question"];
        [newQuestionParameteres setValue:correctIndex forKey:@"correctindex"];
        [newQuestionParameteres setValue:[NSNumber numberWithInt:d]  forKey:@"duration"];
        [newQuestionParameteres setObject:answers forKey:@"answers"];
        
        
        if (self.newQuestionFlag) {
            
//            if (!questionCreatedFlag) {
                [[HttpManager sharedInstance] createLecQuestionWithParameters:newQuestionParameteres successHandler:^(NSDictionary *questionInfo) {
                    
                    NSString *questionId = [questionInfo objectForKey:@"id"];
                    questionCreatedFlag= YES;
                    
                    [[HttpManager sharedInstance] addQuestionWithId:questionId toLecture:self.lecture.  lectureId successHandler:^{
                        
                        self.editFlag = NO;
                        self.newQuestionFlag = NO;
                        questionConnectedToLectureFlag = YES;
                        
                        [self setQuestionTextView];
                        
                        if (self.lecture.questions == nil)
                            self.lecture.questions = [[NSMutableArray alloc] init];
                        
                        self.question = [[LectureQuestion alloc] init];
                        [self.question fromDictionary:newQuestionParameteres];
                        self.question.questionId = questionId;
                        
                        [self.lecture.questions addObject:self.question];
                        
                        [self.tbvAnswers reloadData];
                        [self setBarButonItems];
                        
                        
                    } failureHandler:^(NSError *error) {
                        //                  TO DO:  DELETE QUESTION because fail to connect it to lecture
                    }];
                    
                } failureHandler:^(NSError *error) {
                    [KVNProgress dismissWithCompletion:^{
                        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Create Question", nil)
                                                    subtitle:NSLocalizedString(@"Fail to create question. Please try again.", nil)
                                                        type:TSMessageNotificationTypeMessage];
                    }];
                }];
//            }
//            else{
//                
//            }
            
            
        }
        else{
            
            int d=2;
            
            NSMutableDictionary *questionParameteres = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
            
            [questionParameteres setValue:self.question.questionId forKey:@"path"];
            
            [parameters setValue:self.txtvQuestion.text forKey:@"question"];
            [parameters setValue:correctIndex forKey:@"correctindex"];
            [parameters setValue:[NSNumber numberWithInt:d]  forKey:@"duration"];
            [parameters setObject:answers forKey:@"answers"];
            
            [questionParameteres setObject:parameters forKey:@"parameters"];
            
            [[HttpManager sharedInstance] editLecQuestionWithParameters:questionParameteres successHandler:^(NSDictionary *questionInfo) {
                
                [self.question fromDictionary:parameters];

                self.editFlag = NO;
                [self setQuestionTextView];

                [self setBarButonItems];
                
                [self.tbvAnswers reloadData];
                
            } failureHandler:^(NSError *error) {
                
                [KVNProgress dismissWithCompletion:^{
                    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Edit Question", nil)
                                                subtitle:NSLocalizedString(@"Fail to save changes. Please try again.", nil)
                                                    type:TSMessageNotificationTypeMessage];
                }];
                
            }];
        }
    }
}

-(void)startEditing{
    self.editFlag = YES;
    [self setQuestionTextView];
    [self.tbvAnswers reloadData];
    [self setBarButonItems];
    
}

-(void)cancelEditing{
    
    [currentTextView resignFirstResponder];
    
    if (self.newQuestionFlag) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        self.editFlag = NO;
        [self setQuestionTextView];

        answers = [self.question.answers mutableCopy];
        correctIndex = self.question.correctIndex;
        [self.tbvAnswers reloadData];
        self.txtvQuestion.text = self.question.question;
        [self setBarButonItems];
    }
}

#pragma mark - TextView

-(void)setQuestionTextView{
    
    if (self.editFlag)
        self.txtvQuestion.editable = YES;
    else
        self.txtvQuestion.editable = NO;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    currentTextView = textView;
}

-(void)textViewDidChange:(UITextView *)textView{
    
    if (textView!= self.txtvQuestion) {
        CGPoint currentOffset = self.tbvAnswers.contentOffset;
        
        [UIView setAnimationsEnabled:NO];
        
        [self.tbvAnswers beginUpdates];
        [self.tbvAnswers endUpdates];
        
        [UIView setAnimationsEnabled:YES];
        
        [self.tbvAnswers setContentOffset:currentOffset animated:NO];
    }
    else{
        
    }

}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView != self.txtvQuestion)
        [answers replaceObjectAtIndex:textView.tag withObject:[NSString stringWithString:textView.text]];
}

-(BOOL)textView:(UITextField *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [currentTextView resignFirstResponder];
}


//
//
//-(BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    [textView resignFirstResponder];
//    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
//    {
//        CGPoint buttonPosition = [textView convertPoint:CGPointZero
//                                                  toView: self.tbvAnswers];
//        NSIndexPath *indexPath = [self.tbvAnswers indexPathForRowAtPoint:buttonPosition];
//        
//        [self.tbvAnswers scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
//    }
//    
//    return YES;
//}


#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return [answers count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *answer = (NSString *)[answers objectAtIndex:indexPath.row];
    
    if (self.editFlag) {
        EditQAnswerTableViewCell  *cellEditAnswer = [tableView dequeueReusableCellWithIdentifier:@"EditQAnswerCell"];
        
        if (indexPath.row == correctIndex.integerValue)
            [cellEditAnswer.btnSetCorrectAnswer setImage:[UIImage imageNamed:@"Checked"] forState:UIControlStateNormal];
        else
            [cellEditAnswer.btnSetCorrectAnswer setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        
        [cellEditAnswer.btnSetCorrectAnswer addTarget:self action:@selector(setCorrectAnswer:) forControlEvents:UIControlEventTouchUpInside];
        
        cellEditAnswer.txtvAnswer.delegate = self;
        cellEditAnswer.btnSetCorrectAnswer.tag = indexPath.row;
        cellEditAnswer.txtvAnswer.tag = indexPath.row;
        
        cellEditAnswer.txtvAnswer.text = answer;
        
        return cellEditAnswer;
    }
    else{
        QAnswerTableViewCell  *cellAnswer = [tableView dequeueReusableCellWithIdentifier:@"QAnswerCell"];
        cellAnswer.lblAnswerMark.text = [NSString stringWithFormat:@"%ld)", (long)(indexPath.row+1)];
        
        if (indexPath.row == correctIndex.integerValue){
            [cellAnswer.lblAnswerMark setTextColor:[UIColor greenColor]];
            [cellAnswer.lblAnswer setTextColor:[UIColor greenColor]];
        }
        else{
            [cellAnswer.lblAnswerMark setTextColor:[UIColor blackColor]];
            [cellAnswer.lblAnswer setTextColor:[UIColor blackColor]];
        }
            
        cellAnswer.lblAnswer.text = answer;

        return cellAnswer;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (self.editFlag)
        return 44.0;
    else
        return 0.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (self.editFlag) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width-40.0, 44.0)];
        footer.backgroundColor = [UIColor whiteColor];
        
        
        UIButton *createAnswer = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [createAnswer addTarget:self
                         action:@selector(createAnswer:)
               forControlEvents:UIControlEventTouchUpInside];
        createAnswer.frame = CGRectMake(8.0, 11.0, 22.0, 22.0);
        
        UILabel *answerLbl = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 11.0, 201.0, 21.0)];
        [answerLbl setText:@"Add Answer"];
        [answerLbl setBackgroundColor:[UIColor whiteColor]];
        [answerLbl setTextColor:[UIColor blackColor]];
        
        
        [footer addSubview:createAnswer];
        [footer addSubview:answerLbl];
        
        return footer;
    }
    else
        return nil;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        if (correctIndex.intValue >= indexPath.row){
            if (correctIndex.intValue == indexPath.row) {
                correctIndex = [NSNumber numberWithInt:0];
            }
            else{
                int iv = correctIndex.intValue -1;
                correctIndex = [NSNumber numberWithInt:iv];
            }
        }
        
//        [tableView beginUpdates];
        [answers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [tableView endUpdates];
        [self.tbvAnswers reloadData];
    }
}



- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)createAnswer:(UIButton *)sender{
    NSString *newAnswer = [[NSString alloc] initWithFormat:@"New Answer"];
    [answers addObject:newAnswer];
    [self.tbvAnswers reloadData];
    
    NSLog(@"create ANSWER");
}

-(void)setCorrectAnswer:(UIButton *)sender{
    correctIndex = [NSNumber numberWithInt:(int)sender.tag];
    NSLog(@"%@",correctIndex);
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

@end
