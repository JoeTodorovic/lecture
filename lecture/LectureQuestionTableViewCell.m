//
//  LectureQuestionTableViewCell.m
//  lecture
//
//  Created by Dusan Todorovic on 12/27/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LectureQuestionTableViewCell.h"
#import "GlobalData.h"


@implementation LectureQuestionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lblQuestionDate.textColor = [[GlobalData sharedInstance] getColor:@"extraLightGray"];
    self.lblQuestionText.textColor = [[GlobalData sharedInstance] getColor:@"darkGray"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
