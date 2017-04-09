//
//  ALSendQuestionViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 1/22/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import "ALSendQuestionViewController.h"
#import <KVNProgress/KVNProgress.h>
#import "DayAxisValueFormatter.h"
#import "IntAxisValueFormatter.h"

@import Charts;


@interface ALSendQuestionViewController () <ChartViewDelegate> {
    NSTimer *timer;
    UIBarButtonItem *resultsButton;
    UIVisualEffectView *effectView;
    BarChartView *barChartView;
    NSMutableArray *results;
}

@end

@implementation ALSendQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SET TSMessage
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    //SET table view
    self.tbvAnswers.delegate =self;
    self.tbvAnswers.dataSource = self;
    self.tbvAnswers.estimatedRowHeight = 74.0f;
    self.tbvAnswers.rowHeight = UITableViewAutomaticDimension;
    self.tbvAnswers.separatorColor = [UIColor whiteColor];
    
    [self.tbvAnswers reloadData];
    
    //SET lbl
    self.lblQuestion.text = self.question.question;
    
    //SET SendQuestion button
//    UIBarButtonItem *sendQuestionButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendQuestion)];
//    self.navigationItem.rightBarButtonItem = sendQuestionButton;
    [self setRightItemsSendResults];
    
    //SET notifications
    [self setNotifications];
    
    //Set chart
    barChartView.delegate = self;
    results = [[NSMutableArray alloc] init];
}



-(void)setNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendLecturerQuestionResponse:)
                                                 name:@"sendLecturerQuestionResponseNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getResultsForQuestionResponse:)
                                                 name:@"getResultsForQuestionResponseNotification"
                                               object:nil];
    
}

#pragma mark - NavigationBar Right Button Items

//set send and back button (and results button if resultes at least once received)
-(void)setRightItemsSendResults{
    
    self.navigationItem.hidesBackButton = NO;
    
    if (self.question.resultsFlag) {
        UIBarButtonItem *sendQuestionButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendQuestion)];
        resultsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Results"] style:UIBarButtonItemStylePlain target:self action:@selector(showChart)];

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:sendQuestionButton, resultsButton, nil];
        
    }
    else{
        UIBarButtonItem *sendQuestionButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendQuestion)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:sendQuestionButton, nil];
    }
}

//when chart showes hide back button and replace send and results with close button
-(void)setCloseChartButton{
    self.navigationItem.hidesBackButton = YES;

    UIBarButtonItem *closeChartButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Delete"] style:UIBarButtonItemStylePlain target:self action:@selector(closeChart)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:closeChartButton, nil];
}


#pragma mark - Selectors

-(void)sendQuestion{
    [KVNProgress showWithStatus:@"Sending question..."];
    [[SocketConnectionManager sharedInstance] sendQuestionToListenersWithQid:self.question.questionId andLId:self.lecture.uniqueId];
}

-(void)showChart{
    [[SocketConnectionManager sharedInstance] getResultsForQuestionWithId:self.question.questionId];
    [KVNProgress showWithStatus:@"Refreshing results"];
}

-(void)getResults{
    [[SocketConnectionManager sharedInstance] getResultsForQuestionWithId:self.question.questionId];
}

-(void)sendLecturerQuestionResponse:(NSNotification *)not{
    
    if ([[not.userInfo valueForKey:@"status"] boolValue]) {
        NSLog(@"Question sent successfully");
//        self.navigationItem.hidesBackButton = YES;
        [KVNProgress updateStatus:@"Waiting results"];
        timer=[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getResults) userInfo:nil repeats:NO];
    }
    else{
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:@"Failed to send question, please try again." type:TSMessageNotificationTypeMessage];
        }];
        NSLog(@"Question sending fail");
    }
}

-(void)getResultsForQuestionResponse:(NSNotification *)not{
        
    [self setCloseChartButton];
    
    if ([[not.userInfo valueForKey:@"status"] boolValue]) {
        //Show results show chart
        NSLog(@"Get Results successfully");
        
        //---------------- results received regardless of whether someone answered or not
        self.question.resultsFlag = YES;
        //----------------
        
        if ([not.userInfo valueForKey:@"results"]) {
//            results = [(NSMutableArray *)[not.userInfo valueForKey:@"results"] mutableCopy];
            self.question.results = [(NSArray *)[not.userInfo valueForKey:@"results"] copy];
            
            if ([self checkResults]) {
                [KVNProgress dismissWithCompletion:^{
                    [self barChart];
                }];
            }
            else{
                [KVNProgress dismissWithCompletion:^{
                    
                    [self setRightItemsSendResults];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Results" message:@"No one answered." preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self presentViewController:alertController animated:YES completion:nil];
                    });
                }];
            }
        }

    }
    else{
        
        //If old results exist show them else change resultButton action to showResults
        NSLog(@"Get Results fail");
        
        if ([self checkResults]) {
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:@"Failed to get result, please try again. Last results will be presented." type:TSMessageNotificationTypeMessage];
                [self barChart];
            }];
        }
        else{
            [KVNProgress dismissWithCompletion:^{
                
                [self setRightItemsSendResults];
                [TSMessage showNotificationWithTitle:@"Failed to get result, please try again. Last results will be presented." type:TSMessageNotificationTypeMessage];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Results" message:@"No one answered." preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }]];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self presentViewController:alertController animated:YES completion:nil];
                });
            }];
        }
    }
}

-(void)closeChart{
    [barChartView removeFromSuperview];
    [effectView removeFromSuperview];
    
    [self setRightItemsSendResults];
}


#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.question.answers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QAnswerTableViewCell *cellAnswer = [tableView dequeueReusableCellWithIdentifier:@"ALSendQuestionCell"];
    cellAnswer.lblAnswerMark.text = [NSString stringWithFormat:@"%ld)", (long)(indexPath.row+1)];
    
    if (indexPath.row == self.question.correctIndex.integerValue){
        [cellAnswer.lblAnswerMark setTextColor:[UIColor greenColor]];
        [cellAnswer.lblAnswer setTextColor:[UIColor greenColor]];
    }
    else{
        [cellAnswer.lblAnswerMark setTextColor:[UIColor blackColor]];
        [cellAnswer.lblAnswer setTextColor:[UIColor blackColor]];
    }
    
    cellAnswer.lblAnswer.text = (NSString *)[self.question.answers objectAtIndex:indexPath.row];
    
    return cellAnswer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView{
    NSLog(@"chartValueNothingSelected");
}

-(void)barChart{
    
    CGRect chartFrame = CGRectMake(0, 0, self.view.frame.size.width-10, self.view.frame.size.height-10);
    barChartView = [[BarChartView alloc] initWithFrame:chartFrame];

    barChartView.center = CGPointMake( self.view.superview.frame.size.width  / 2, self.view.superview.frame.size.height / 2);

    //------
    barChartView.chartDescription.enabled = NO;
    
    barChartView.drawGridBackgroundEnabled = NO;
    
    barChartView.dragEnabled = YES;
    [barChartView setScaleEnabled:YES];
    barChartView.pinchZoomEnabled = NO;
    
    barChartView.rightAxis.enabled = NO;
    
    barChartView.doubleTapToZoomEnabled = NO;
    barChartView.highlightPerTapEnabled = NO;
    barChartView.highlightPerDragEnabled = NO;

    //------
    
    
    barChartView.drawBarShadowEnabled = NO;
    barChartView.drawValueAboveBarEnabled = YES;
    
    barChartView.maxVisibleCount = 60;
    

    ChartXAxis *xAxis = barChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:14.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0; // only intervals of 1 day
    xAxis.labelCount = 7;
    xAxis.valueFormatter = [[IntAxisValueFormatter alloc] initForChart:barChartView];
    
    
    ChartYAxis *leftAxis = barChartView.leftAxis;
    leftAxis.drawLabelsEnabled = NO;
    leftAxis.drawAxisLineEnabled = NO;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.drawZeroLineEnabled = YES;

    
    
    ChartLegend *l = barChartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    l.form = ChartLegendFormSquare;
    l.formSize = 9.0;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    l.xEntrySpace = 4.0;

    
    //SET data
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
//    [yVals addObject:[[BarChartDataEntry alloc] initWithX:0.0f y:30]];
//    [yVals addObject:[[BarChartDataEntry alloc] initWithX:1.0f y:20]];
//    [yVals addObject:[[BarChartDataEntry alloc] initWithX:2.0f y:8]];
//    [yVals addObject:[[BarChartDataEntry alloc] initWithX:3.0f y:13]];
//    unsigned int i, cnt = [results count];


    for (int i=0; i<[self.question.results count]; i++) {
        [yVals addObject:[[BarChartDataEntry alloc] initWithX:i y:[(NSNumber *)self.question.results[i] doubleValue]]];
    }
    

    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithValues:yVals];
    [dataSet setColors:ChartColorTemplates.material];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:dataSet];
    
    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    data.barWidth = 0.9f;
    
    barChartView.data = data;
    
    // create blur effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // create vibrancy effect
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
    
    // add blur to an effect view
    effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add vibrancy to yet another effect view
    UIVisualEffectView *vibrantView = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
    vibrantView.frame = self.view.frame;
    
    [self.view.superview addSubview:effectView];
//    [self.view.superview addSubview:vibrantView];
    
    [self.view.superview addSubview:barChartView];
    
    self.navigationItem.hidesBackButton = YES;

}

-(void)showResults{
    
    if ([self checkResults]) {
        [KVNProgress dismissWithCompletion:^{
            [self setCloseChartButton];
            [self barChart];
        }];
    }
    else{
        [KVNProgress dismissWithCompletion:^{
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Results" message:@"No one answered." preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                
                
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }];
    }
}

-(BOOL)checkResults{
    //checking if anyone answered, if not then there is no data to present
    
    for (NSNumber *i in self.question.results) {
        if ([i intValue] != 0)
            return YES;
    }
    return NO;
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
