//
//  GlobalData.h
//  lecture
//
//  Created by Dusan Todorovic on 12/1/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalData : NSObject {
    NSMutableDictionary *colors;
}

+ (GlobalData *)sharedInstance;

+ (Boolean)getOrientation:(UIViewController *)view;

+ (NSString *)timeFormat:(NSNumber *)number;
+ (NSString *)sizeFormat:(NSNumber *)number;

+ (NSString *)dateToString:(NSDate *)date;
+ (NSString *)timeToString:(NSDate *)date;
+ (NSString *)dayToString:(NSDate *)date;
+ (NSString *)timestampToString:(NSDate *)timestamp;
+ (NSDate *)timestampStringToDate:(NSString *)timestamp;
+ (NSDate *)stringToDate:(NSString *)dateString;
+ (NSString *)dateToStringV2:(NSDate *)date;
+ (NSString *)dateToStringV3:(NSDate *)date;
+ (NSString *)classicDayToString:(NSDate *)date;

+ (NSString *)stringToFrontTime:(NSString *)stringDate;
+ (NSString *)stringToFrontDay:(NSString *)stringDate;

-(NSNumber *)stringToNumber:(NSString *)string;

- (UIColor *)getColor:(NSString *)name;

-(NSMutableArray *)sortLists:(NSMutableArray *)listsToSort;
-(NSArray *)removeEmptyArraysFrom:(NSArray *)array;

@end
