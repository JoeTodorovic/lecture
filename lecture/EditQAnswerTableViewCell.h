//
//  EditQAnswerTableViewCell.h
//  lecture
//
//  Created by Dusan Todorovic on 1/4/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditQAnswerTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextView *txtvAnswer;

@property (strong, nonatomic) IBOutlet UIButton *btnSetCorrectAnswer;
- (IBAction)btnSetCorrectAnswerPressed:(id)sender;

@end
