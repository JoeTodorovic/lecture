//
//  LecturerHomeViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 12/7/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LectureTableViewCell.h"
#import "LectureViewController.h"

#import "HttpManager.h"
#import "LecturerManager.h"
#import "LecturerUser.h"
#import "Lecture.h"

#import "TSMessage.h"
#import "TSMessageView.h"

@interface LecturerHomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,TSMessageViewProtocol>


@property (strong, nonatomic) IBOutlet UITableView *tvLectures;

- (IBAction)bbiCreateLecturePressed:(id)sender;


@end
