//
//  GlobalData.m
//  lecture
//
//  Created by Dusan Todorovic on 12/1/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData



#pragma mark -
#pragma mark Singleton Methods
+ (GlobalData *)sharedInstance {
    static GlobalData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GlobalData alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if ((self = [super init])) {
        [self initColours];
    }
    return self;
}




+ (Boolean)getOrientation:(UIViewController *)view {
    return (! (view.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
               view.interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


+ (NSString *)timeFormat:(NSNumber *)number {
    NSInteger total = [number integerValue];
    
    NSInteger time_hrs = total / 3600;
    total = total - 3600 * time_hrs;
    NSInteger time_mins = total / 60;
    total = total - 60 * time_mins;
    NSInteger time_secs = total;
    
    //    NSString *retVal = [NSString stringWithFormat:@"%f",[number floatValue]];
    NSString *retVal = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)time_hrs, (long)time_mins, (long)time_secs];
    
    return retVal;
}


+ (NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy  HH:mm"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

+ (NSString *)dateToStringV3:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

+ (NSString *)stringToFrontDay:(NSString *)stringDate{
    NSDate *date = [self stringToDate:stringDate];
    NSString *day = [self dayToString:date];
    return day;
}

+ (NSString *)stringToFrontTime:(NSString *)stringDate{
    NSDate *date = [self stringToDate:stringDate];
    NSString *time = [self timeToString:date];
    return time;
}

+ (NSDate *)stringToDate:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}


+ (NSString *)timeToString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

+ (NSString *)dayToString:(NSDate *)date {
    
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    
    if([today day] == [otherDay day] && [today month] == [otherDay month] && [today year] == [otherDay year] && [today era] == [otherDay era]){
        NSString *day = [[NSString alloc] initWithFormat:@"Today"];
        return day;
    }
    else {
        if ([today day]-1 == ([otherDay day]) && [today month] == [otherDay month] && [today year] == [otherDay year] && [today era] == [otherDay era]){
            NSString *day = [[NSString alloc] initWithFormat:@"Yesterday"];
            return day;
        }
        else{
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            
            //Optionally for time zone converstions
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
            
            NSString *stringFromDate = [formatter stringFromDate:date];
            
            return stringFromDate;
        }
    }
}

+ (NSString *)classicDayToString:(NSDate *)date {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
    
}

+ (NSString *)dateToStringV2:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}


+ (NSString *)timestampToString:(NSDate *)timestamp {
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    //    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    //    [timeFormatter setDateFormat:@"hh:mm a"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //    //Optionally for time zone converstions
    //    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:timestamp];
    //    NSLog(@"Timestamp :%@", stringFromDate);
    
    return stringFromDate;
}


+ (NSDate *)timestampStringToDate:(NSString *)timestamp {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    NSNumber *timestampNumber = [formatter numberFromString:timestamp];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestampNumber doubleValue]];
    
    NSLog(@"Date :%@", date);
    
    return date;
}

#pragma mark - string to NSNumber

-(NSNumber *)stringToNumber:(NSString *)string{
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [f numberFromString:string];
}

#pragma mark - lists sorting

-(NSMutableArray *)sortLists:(NSMutableArray *)listsToSort{
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"client_time" ascending:NO];
    
    [listsToSort sortUsingDescriptors: [NSArray arrayWithObjects: dateDescriptor, nil]];
    
    return listsToSort;
}


-(NSArray *)removeEmptyArraysFrom:(NSArray *)array{
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSArray *arr in array) {
        if ([arr count] > 0) {
            //            if ([[arr objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
            //                NSDictionary *dict =(NSDictionary *)[arr objectAtIndex:0];
            [result addObject:[arr objectAtIndex:0]];
            //                NSLog(@"%@", arr[0]);
            //            }
        }
    }
    
    return [[NSArray alloc] initWithArray:result];
}

# pragma mark - custom colors

- (void)initColours {
    colors = [[NSMutableDictionary alloc] init];
    
    [colors setObject:[UIColor colorWithRed:57.0/255.0 green:155.0/255.0 blue:232.0/255.0 alpha:1.0] forKey:@"blue"];
    
    
    
}

- (UIColor *)getColor:(NSString *)name {
    return [colors objectForKey:name];
}

@end
