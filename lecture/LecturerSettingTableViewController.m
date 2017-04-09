//
//  LecturerSettingTableViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LecturerSettingTableViewController.h"

@interface LecturerSettingTableViewController ()

@end

@implementation LecturerSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.txtfFirstName.text = [LecturerManager sharedInstance].userProfile.firstName;
    self.txtfLastName.text = [LecturerManager sharedInstance].userProfile.lastName;
    self.txtfEmail.text = [LecturerManager sharedInstance].userProfile.email;
    self.txtfTitle.text = [LecturerManager sharedInstance].userProfile.title;
    self.txtfUniversity.text = [LecturerManager sharedInstance].userProfile.university;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.bbiSave;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 5;
    }
    else{
        return 1;
    }
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    cell.accessoryView.tintColor = [UIColor whiteColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
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


#pragma mark - TextField and Keyboard

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtfFirstName resignFirstResponder];
    [self.txtfLastName resignFirstResponder];
    [self.txtfEmail resignFirstResponder];
    [self.txtfUniversity resignFirstResponder];
    [self.txtfTitle resignFirstResponder];
    
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextField *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}

//- (void)keyboardWillShow:(NSNotification *)note
//{
//    CGFloat height = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    
//    [UIView animateWithDuration:0.4 animations:^{
//        
//        self.view.transform = CGAffineTransformMakeTranslation(0, -height);
//        
//    }];
//}
//
//- (void)keyboardWillHide:(NSNotification *)note
//{
//    [UIView animateWithDuration:0.05 animations:^{
//        
//        self.view.transform = CGAffineTransformIdentity;
//    }];
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)bbiSavePressed:(id)sender {
    
    NSDictionary *newParameters = @{@"firstname" : self.txtfFirstName.text, @"lastname" : self.txtfLastName.text, @"title" : self.txtfTitle.text, @"university" : self.txtfUniversity.text};
    
    [[HttpManager sharedInstance] editUserWithParameters:newParameters successHandler:^(NSDictionary *regInfo) {
        NSLog(@"EDIT_USER successHandler");
        
        [[LecturerManager sharedInstance].userProfile updateWithDictionary:newParameters];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } failureHandler:^(NSError *error) {
        NSLog(@"EDIT_USER failureHandler");

    }];
}
@end
