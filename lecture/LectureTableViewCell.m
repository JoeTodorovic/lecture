//
//  LectureTableViewCell.m
//  lecture
//
//  Created by Dusan Todorovic on 12/7/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LectureTableViewCell.h"
#import "GlobalData.h"

@implementation LectureTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textLabel.textColor = [[GlobalData sharedInstance] getColor:@"darkGray"];
    self.detailTextLabel.textColor = [[GlobalData sharedInstance] getColor:@"extraLightGray"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
