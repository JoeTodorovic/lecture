//
//  ChangePasswordTableViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 2/16/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import "ChangePasswordTableViewController.h"

@interface ChangePasswordTableViewController (){
    BOOL cpSecureFlag;
    BOOL npSecureFlag;
}

@end

@implementation ChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cpSecureFlag = YES;
    cpSecureFlag = YES;
    
    self.txtfCurrentPassword.delegate = self;
    self.txtfNewPassword.delegate = self;
    
    //SET table view
    self.tableView.tableFooterView = [[UIView alloc] init]; //don't show blank cells
    
    //SET SaveChanges button
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem =;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - selectors

-(void)saveChanges{
    
    //TO DO: check if current enterd password is corect, then update profile
    
    
//    if (self.txtfCurrentPassword isEqual:[LecturerManager sharedInstance].userProfile.) {
//        <#statements#>
//    }
    NSDictionary *newParameters = @{@"password" : self.txtfNewPassword.text};
    
    [[HttpManager sharedInstance] editUserWithParameters:newParameters successHandler:^(NSDictionary *regInfo) {
        NSLog(@"EDIT_USER successHandler");
        
        [[LecturerManager sharedInstance].userProfile updateWithDictionary:newParameters];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } failureHandler:^(NSError *error) {
        NSLog(@"EDIT_USER failureHandler");
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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

- (IBAction)btnSecureCPPressed:(id)sender {
    
    if (cpSecureFlag) {
        cpSecureFlag = NO;
        self.txtfCurrentPassword.secureTextEntry = NO;
        [self.btnSecureCP setImage:[UIImage imageNamed:@"Visible"] forState:UIControlStateNormal];
    }
    else{
        cpSecureFlag = YES;
        self.txtfCurrentPassword.secureTextEntry = YES;
        [self.btnSecureCP setImage:[UIImage imageNamed:@"Invisible"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnSecureNPPressed:(id)sender {
    
    if (npSecureFlag) {
        npSecureFlag = NO;
        self.txtfNewPassword.secureTextEntry = NO;
        [self.btnSecureNP setImage:[UIImage imageNamed:@"Visible"] forState:UIControlStateNormal];

    }
    else{
        npSecureFlag = YES;
        self.txtfNewPassword.secureTextEntry = YES;
        [self.btnSecureNP setImage:[UIImage imageNamed:@"Invisible"] forState:UIControlStateNormal];

    }
}
@end
