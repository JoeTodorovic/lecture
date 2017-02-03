//
//  LecturerSettingTableViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LecturerManager.h"
#import "LecturerUser.h"
#import "HttpManager.h"

@interface LecturerSettingTableViewController : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtfFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtfLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtfEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtfTitle;
@property (strong, nonatomic) IBOutlet UITextField *txtfUniversity;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiSave;


- (IBAction)bbiSavePressed:(id)sender;

@end
