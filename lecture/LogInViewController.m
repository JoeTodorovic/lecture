//
//  LogInViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LogInViewController.h"
#import <KVNProgress/KVNProgress.h>

#import "TSMessage.h"
#import "TSMessageView.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    
//    self.txtfEmailUsername.text = @"jako@qqqq.com";
//    self.txtfPassword.text = @"123";
    self.txtfEmailUsername.text = @"newone@www.com";
    self.txtfPassword.text = @"123";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDissappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - TextField and Keyboard

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.txtfEmailUsername resignFirstResponder];
    [self.txtfPassword resignFirstResponder];
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

- (void)keyboardWillShow:(NSNotification *)note
{
    CGFloat height = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.view.transform = CGAffineTransformMakeTranslation(0, -height);
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.05 animations:^{
        
        self.view.transform = CGAffineTransformIdentity;
    }];
    
}



#pragma mark - Email check
-(BOOL) stringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnLogInPressed:(id)sender {
    
    [KVNProgress showWithStatus:@"Logging in..."];
    
    
    [[HttpManager sharedInstance] loginUserWithEmail:self.txtfEmailUsername.text password:self.txtfPassword.text successHandler:^(NSDictionary *myInfo) {
        NSLog(@"LOGIN successHandler");
        
        [[HttpManager sharedInstance] getUserWithEmail:self.txtfEmailUsername.text successHandler:^(NSDictionary *userInfo) {
            NSLog(@"GET_USER successHandler");
            
            [KVNProgress updateStatus:@"Loading user data..."];
            if (userInfo!= nil) {
                
                [LecturerManager sharedInstance].userProfile = [[LecturerUser alloc] init];
                [[LecturerManager sharedInstance].userProfile createWithDictionary:userInfo];
                
                if ([userInfo objectForKey:@"lectures"]) {
                    NSArray *lectures = (NSArray *)[userInfo objectForKey:@"lectures"];
                    for (NSDictionary *lectureDict in lectures) {
                        Lecture *lecture = [[Lecture alloc] init];
                        [lecture fromDictionary:lectureDict];
                        [[LecturerManager sharedInstance].lectures addObject:lecture];
                    }
                }
            }
            
            if ([userInfo valueForKey:@"runninglecture"]) {
                
//                Lecture *runningLecture = [[LecturerManager sharedInstance] getLectureWithUniqueId:(NSString *)[userInfo objectForKey:@"runninglecture"]];
                [LecturerManager sharedInstance].runningLectureUniqueId = [[NSString alloc] initWithFormat:@"%@",[userInfo valueForKey:@"runninglecture"]];
                [LecturerManager sharedInstance].loginToLectureFlag = YES;

//                if (runningLecture != nil) {
//                    [[HttpManager sharedInstance] getLectureWithId:runningLecture.lectureId successHandler:^(NSDictionary *lectureInfo) {
//                        
//                        if (lectureInfo != nil) {
//                            
//                            [runningLecture fromDictionary:lectureInfo];
//                            [LecturerManager sharedInstance].loginToLectureFlag = YES;
//                            
//                            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                                     selector:@selector(initSocketConnectionFail:)
//                                                                         name:@"socketConnectionFailResponseNotification"
//                                                                       object:nil];
//                            
//                            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                                     selector:@selector(socketLoginResponse:)
//                                                                         name:@"loginResponseNotification"
//                                                                       object:nil];
//                            [[SocketConnectionManager sharedInstance] initSocketConnection];
////                            UITabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"ManiTabBarControllerSID"];
////
////                            [self.navigationController pushViewController:tabBar animated:NO];
//                        }
//                    } failureHandler:^(NSError *error) {
//                        
//                    }];
//                }
                
                UITabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"ManiTabBarControllerSID"];
                
                [self.navigationController pushViewController:tabBar animated:NO];
                [KVNProgress dismiss];
            }
            else{

                [self performSegueWithIdentifier:@"LogInToLecturerHomeSegue" sender:self];
                [KVNProgress dismiss];

            }
        
        } failureHandler:^(NSError *error) {
            NSLog(@"GET_USER failureHandler");
            
            [KVNProgress dismissWithCompletion:^{
                [TSMessage showNotificationWithTitle:NSLocalizedString(@"Loading user data fail, try to login again.", nil)
                                            subtitle:nil
                                                type:TSMessageNotificationTypeMessage];
            }];
        }];

    } failureHandler:^(NSError *error) {
        NSLog(@"LOGIN failureHandler");
        
        [KVNProgress dismissWithCompletion:^{
            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Logging in fail. Please Try again.", nil)
                                        subtitle:nil
                                            type:TSMessageNotificationTypeMessage];
        }];
    }];
    
}

- (IBAction)btnBackPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

//-(void)initSocketConnectionFail:(NSNotification *)not{
//    
//    NSLog(@"Fail to connect to socket");
//    // TO DO SHOW INFO
//}
//
//-(void)socketLoginResponse:(NSNotification *)not{
//    
//    self.activitiIndicator.hidden  = YES;
//    [self.activitiIndicator stopAnimating];
//    self.view.userInteractionEnabled = YES;
//    
//    if ([((NSNumber *)[not.userInfo valueForKey:@"status"]) boolValue]) {
//        UITabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"ManiTabBarControllerSID"];
//        
//        [self.navigationController pushViewController:tabBar animated:NO];
//    }
//    else{
//        //TO DO SHOW INFO
//    };
//}

@end
