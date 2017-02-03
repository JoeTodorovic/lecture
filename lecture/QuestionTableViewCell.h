//
//  QuestionTableViewCell.h
//  lecture
//
//  Created by Dusan Todorovic on 11/30/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblQuestionText;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;

@end
