//
//  CreateLectureViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "CreateLectureViewController.h"

@interface CreateLectureViewController (){
    Lecture *newLecture;
}


@end

@implementation CreateLectureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnCreateLecturePressed:(id)sender {
    
    
    if (![self.txtfName.text isEqualToString:@""]) {
        
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden =NO;
        self.view.userInteractionEnabled = NO;
        self.txtfName.alpha = 0.5;
        self.txtvDescription.alpha = 0.5;
        self.btnCancel.alpha = 0.5;
        self.btnCreate.alpha = 0.5;
        
        NSDictionary *parameters = @{@"title" : self.txtfName.text,
                                     @"description" : self.txtvDescription.text};
        
        [[HttpManager sharedInstance] createLectureWithParameters:parameters successHandler:^(NSString *lectureId) {
            
            NSLog(@"CREATE_LECTURE successHandler");
            
            [[HttpManager sharedInstance] getLectureWithId:lectureId successHandler:^(NSDictionary *lectureInfo) {
                
                NSLog(@"Get_LECTURE successHandler");
                newLecture = [[Lecture alloc] init];
                [newLecture fromDictionary:lectureInfo];
                [[LecturerManager sharedInstance].lectures addObject:newLecture];
                
                [self performSegueWithIdentifier:@"CreateLectureToLectureSegue" sender:self];
                
                [self.activityIndicator startAnimating];
                self.activityIndicator.hidden =YES;
                self.view.userInteractionEnabled = YES;
                self.txtfName.alpha = 1;
                self.txtvDescription.alpha = 1;
                self.btnCancel.alpha = 1;
                self.btnCreate.alpha = 1;
                
            } failureHandler:^(NSError *error) {
                NSLog(@"Get_LECTURE failureHandler");
                
                [self.activityIndicator startAnimating];
                self.activityIndicator.hidden =YES;
                self.view.userInteractionEnabled = YES;
                self.txtfName.alpha = 1;
                self.txtvDescription.alpha = 1;
                self.btnCancel.alpha = 1;
                self.btnCreate.alpha = 1;
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:nil
                                             message:@"Create new lecture failed"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okButton = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self dismissViewControllerAnimated:alert completion:^{
                                                    
                                                }];
                                            }];
                
                
                [alert addAction:okButton];
                
                [self presentViewController:alert animated:YES completion:nil];
            }];
            
        } failureHandler:^(NSError *error) {
            
            NSLog(@"CREATE_LECTURE failureHandler");
            
            [self.activityIndicator startAnimating];
            self.activityIndicator.hidden =YES;
            self.view.userInteractionEnabled = YES;
            self.txtfName.alpha = 1;
            self.txtvDescription.alpha = 1;
            self.btnCancel.alpha = 1;
            self.btnCreate.alpha = 1;
        }];
    }
    else{
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Title"
                                     message:@"Please enter lectures name."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                       
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"CreateLectureToLectureSegue"]){
        LectureViewController *vc = segue.destinationViewController;
        vc.lecture = newLecture;
        vc.newLectureFlag = YES;
    }
}

@end
