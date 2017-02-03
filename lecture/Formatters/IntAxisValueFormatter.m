//
//  IntAxisValueFormatter.m
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

#import "IntAxisValueFormatter.h"

@implementation IntAxisValueFormatter
{
    __weak BarLineChartViewBase *_chart;
    NSArray *answers;
}

- (id)initForChart:(BarLineChartViewBase *)chart
{
    self = [super init];
    if (self)
    {
        self->_chart = chart;
        
        answers = @[
                   @"A", @"B", @"C",
                   @"D", @"E", @"F",
                   @"G", @"H", @"I",
                   @"J", @"K", @"L"
                   ];
    }
    return self;
}

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
//    return [@((NSInteger)value) stringValue];
    return [answers objectAtIndex:(NSUInteger)value];

}

@end
