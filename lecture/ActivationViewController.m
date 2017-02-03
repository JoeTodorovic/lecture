//
//  ActivationViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "ActivationViewController.h"

@interface ActivationViewController ()

@end

@implementation ActivationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnActivatePressed:(id)sender {
    [self performSegueWithIdentifier:@"ActivationToLecturerHomeSegue" sender:self];
}
@end
