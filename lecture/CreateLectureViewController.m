//
//  CreateLectureViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/13/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "CreateLectureViewController.h"

#import <KVNProgress/KVNProgress.h>

@interface CreateLectureViewController (){
    Lecture *newLecture;
}


@end

@implementation CreateLectureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //SET TSMessage
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnCreateLecturePressed:(id)sender {
    
    [KVNProgress showWithStatus:@"Creating New Lecture..."];
    
    if (![self.txtfName.text isEqualToString:@""]) {
        
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
                
                [KVNProgress dismiss];
                
            } failureHandler:^(NSError *error) {
                NSLog(@"Get_LECTURE failureHandler");

                //TO DO what when fail to get lecture

                [KVNProgress dismissWithCompletion:^{
//                    [TSMessage showNotificationWithTitle:@"Create Lecture" subtitle:@"Fail to create Lecture. Please try again." type:TSMessageNotificationTypeMessage];
                }];
            }];
            
        } failureHandler:^(NSError *error) {
            
            NSLog(@"CREATE_LECTURE failureHandler");
            
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:@"Create Lecture" subtitle:@"Fail to create Lecture. Please try again." type:TSMessageNotificationTypeMessage];
            }];
            
        }];
    }
    else{
        
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:@"Please enter Lecture name." type:TSMessageNotificationTypeMessage];
        }];
        
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
