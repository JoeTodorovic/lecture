//
//  LectureWallTableViewCell.h
//  lecture
//
//  Created by Dusan Todorovic on 1/17/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LectureWallTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblWallQuestion;

@property (strong, nonatomic) IBOutlet UIButton *btnDisplay;

@end
