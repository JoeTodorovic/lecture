//
//  EditLectureTableViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 2/4/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import "EditLectureTableViewController.h"
#import <KVNProgress/KVNProgress.h>

@interface EditLectureTableViewController ()

@end

@implementation EditLectureTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //SET lecture data
    if (self.lecture.name && ![self.lecture.name isEqualToString:@""])
        self.txtfTitle.text = self.lecture .name;
    
    if (self.lecture.lectureDescription && ![self.lecture.lectureDescription isEqualToString:@""])
        self.txtfDescription.text = self.lecture.lectureDescription;
    
    if (self.lecture.password && ![self.lecture.password isEqualToString:@""]){
        self.txtfPassword.text = self.lecture.password;
        [self.switchPassword setOn:YES];
    }
    else{
        self.txtfPassword.enabled = NO;
        [self.switchPassword setOn:NO];
    }
    
    //SET textFields
    self.txtfTitle.delegate = self;
    self.txtfPassword.delegate = self;
    self.txtfDescription.delegate = self;
    
    
    //SET Navigation
//    [self.navigationController setNavigationBarHidden:NO];
    [self setBarButtonItems];
    
    //SET table view
    self.tableView.tableFooterView = [[UIView alloc] init]; //don't show blank cells
    
    //SET TSMessage
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];

    //SET never go to sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)dealloc{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setBarButtonItems{
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveEditing)];
    
//    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)];
}

#pragma mark - Selectors

-(void)saveEditing{
    
    [self.txtfPassword resignFirstResponder];
    [self.txtfDescription resignFirstResponder];
    [self.txtfTitle resignFirstResponder];
    
    NSMutableDictionary *parametars = [[NSMutableDictionary alloc] init];
    
    [parametars setValue:self.lecture.lectureId forKey:@"guid"];
    
    if (![self.txtfTitle.text isEqualToString:@""] && self.txtfTitle.text != nil) {
        [parametars setValue:self.txtfTitle.text forKey:@"title"];
    }
    else{
        [TSMessage showNotificationWithTitle:@"Please enter lecture title." type:TSMessageNotificationTypeMessage];
        return;
    }
    
    if (![self.txtfDescription.text isEqualToString:@""] && self.txtfDescription.text != nil) {
        [parametars setValue:self.txtfDescription.text forKey:@"description"];
    }

    if (![self.txtfPassword.text isEqualToString:@""] && self.txtfPassword.text != nil && self.switchPassword.isOn) {
        [parametars setValue:self.txtfPassword.text forKey:@"title"];
    }
    

    [KVNProgress showWithStatus:@"Saving changes..."];
    [[HttpManager sharedInstance] editLectureWithParameters:parametars successHandler:^(NSDictionary *lectureInfo) {
        
        if (lectureInfo) {
            [self.lecture fromDictionary:lectureInfo];
        }
        [KVNProgress dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];

    } failureHandler:^(NSError *error) {
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:@"Fail to save changes. Please try again" type:TSMessageNotificationTypeMessage];
        }];
    }];
}

-(void)cancelEditing{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)switchPasswordChanged:(id)sender {
    if (self.switchPassword.isOn) {
        self.txtfPassword.enabled = YES;
    }
    else{
        self.txtfPassword.enabled = NO;
        self.txtfPassword.text = nil;
        [self.txtfPassword resignFirstResponder];
    }
}
@end
