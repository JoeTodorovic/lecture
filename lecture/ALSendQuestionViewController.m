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
    PieChartView *chartView;
    
    BarChartView *barChartView;
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
    
    //SEND Question button
    UIBarButtonItem *sendQuestionButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendQuestion)];
    self.navigationItem.rightBarButtonItem = sendQuestionButton;
    
    
    [self setNotifications];
    
    
    chartView.delegate = self;
    barChartView.delegate = self;
    
    [self barChart];


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


#pragma mark - Selectors

-(void)sendQuestion{
    [KVNProgress showWithStatus:@"Sending question..."];
    [[SocketConnectionManager sharedInstance] sendQuestionToListenersWithQid:self.question.questionId andLId:self.lecture.uniqueId];
}

-(void)showChart{
    [self barChart];

}

-(void)getResults{
    [[SocketConnectionManager sharedInstance] getResultsForQuestionWithId:self.question.questionId];
}

-(void)sendLecturerQuestionResponse:(NSNotification *)not{
    
    if ([[not.userInfo valueForKey:@"status"] boolValue]) {
        NSLog(@"Question sent successfully");
//        self.navigationItem.hidesBackButton = YES;
        [KVNProgress updateStatus:@"Waiting results"];
        timer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getResults) userInfo:nil repeats:NO];
    }
    else{
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:@"Failed to send question, please try again." type:TSMessageNotificationTypeMessage];
        }];
        NSLog(@"Question sending fail");
    }
}

-(void)getResultsForQuestionResponse:(NSNotification *)not{
    
    UIBarButtonItem *resultsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Results"] style:UIBarButtonItemStylePlain target:self action:@selector(showChart)];
    self.navigationItem.rightBarButtonItem = resultsButton;
    
    if ([[not.userInfo valueForKey:@"status"] boolValue]) {
        NSLog(@"Get Results successfully");
        [KVNProgress dismiss];
    }
    else{
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:@"Failed to get result, please try again." type:TSMessageNotificationTypeMessage];

        }];
        NSLog(@"Get Results fail");
    }
}


#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.question.answers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QAnswerTableViewCell *cellAnswer = [tableView dequeueReusableCellWithIdentifier:@"ALSendQuestionCell"];
    cellAnswer.lblAnswerMark.text = [NSString stringWithFormat:@"%ld)", (long)(indexPath.row+1)];
    
    if (indexPath.row == self.question.correctIndex.integerValue-1){
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

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

-(void)barChart{
    
    CGRect chartFrame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.width);
    barChartView = [[BarChartView alloc] initWithFrame:chartFrame];

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
    
    [yVals addObject:[[BarChartDataEntry alloc] initWithX:0.0f y:30]];
    [yVals addObject:[[BarChartDataEntry alloc] initWithX:1.0f y:20]];
    [yVals addObject:[[BarChartDataEntry alloc] initWithX:2.0f y:8]];
    [yVals addObject:[[BarChartDataEntry alloc] initWithX:3.0f y:13]];
    

    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithValues:yVals];
    [dataSet setColors:ChartColorTemplates.material];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:dataSet];
    
    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    data.barWidth = 0.9f;
    
    barChartView.data = data;
    

    [self.view addSubview:barChartView];
}

-(void)pieChart{
    
    CGRect chartframe = CGRectMake(20, 50, self.view.frame.size.width, self.view.frame.size.width);
    chartView = [[PieChartView alloc] initWithFrame:chartframe];
    //    chartView.backgroundColor = [uicol/]
    chartView.usePercentValuesEnabled = YES;
    chartView.drawSlicesUnderHoleEnabled = NO;
    chartView.holeRadiusPercent = 0.58;
    chartView.transparentCircleRadiusPercent = 0.61;
    chartView.chartDescription.enabled = NO;
    [chartView setExtraOffsetsWithLeft:5.f top:10.f right:5.f bottom:5.f];
    
    chartView.drawCenterTextEnabled = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"Charts\nby Daniel Cohen Gindi"];
    [centerText setAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f],
                                NSParagraphStyleAttributeName: paragraphStyle
                                } range:NSMakeRange(0, centerText.length)];
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f],
                                NSForegroundColorAttributeName: UIColor.grayColor
                                } range:NSMakeRange(10, centerText.length - 10)];
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.f],
                                NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]
                                } range:NSMakeRange(centerText.length - 19, 19)];
    chartView.centerAttributedText = centerText;
    
    chartView.drawHoleEnabled = YES;
    chartView.rotationAngle = 0.0;
    chartView.rotationEnabled = YES;
    chartView.highlightPerTapEnabled = YES;
    
    ChartLegend *l = chartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationVertical;
    l.drawInside = NO;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;
    
    
    //SET data
    int asciiCode = 65;
    
    int count = 4;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    NSArray *results = @[@90, @5, @4, @1];
    
    for (int i = 0; i < count; i++)
    {
        NSString *string = [NSString stringWithFormat:@"%c", asciiCode+i];
        [values addObject:[[PieChartDataEntry alloc] initWithValue:((NSNumber *)[results objectAtIndex:i]).doubleValue label:[NSString stringWithFormat:@"%@)", string]]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:values label:@"nil"];
    dataSet.sliceSpace = 2.0;
    
    // add a lot of colors
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:UIColor.whiteColor];
    
    chartView.data = data;
    [chartView highlightValues:nil];
    
    //Show View
    [self.view addSubview:chartView];
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
