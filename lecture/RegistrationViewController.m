//
//  RegistrationViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "RegistrationViewController.h"

#import "GlobalData.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtfEmail.layer.cornerRadius = 11.0;
    self.txtfEmail.layer.borderWidth = 0.75;
    self.txtfEmail.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.txtfEmail.textColor = [UIColor darkGrayColor];

    self.txtfTitle.layer.cornerRadius = 11.0;
    self.txtfTitle.layer.borderWidth = 0.75;
    self.txtfTitle.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.txtfTitle.textColor = [UIColor darkGrayColor];

    self.txtfLastName.layer.cornerRadius = 11.0;
    self.txtfLastName.layer.borderWidth = 0.75;
    self.txtfLastName.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.txtfLastName.textColor = [UIColor darkGrayColor];

    self.txtfUniversity.layer.cornerRadius = 11.0;
    self.txtfUniversity.layer.borderWidth = 0.75;
    self.txtfUniversity.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.txtfUniversity.textColor = [UIColor darkGrayColor];

    self.txtfFirstName.layer.cornerRadius = 11.0;
    self.txtfFirstName.layer.borderWidth = 0.75;
    self.txtfFirstName.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.txtfFirstName.textColor = [UIColor darkGrayColor];

    self.txtfPassword.layer.cornerRadius = 11.0;
    self.txtfPassword.layer.borderWidth = 0.75;
    self.txtfPassword.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.txtfPassword.textColor = [UIColor darkGrayColor];

    [self.btnRegister setTitleColor:[[GlobalData sharedInstance] getColor:@"red"] forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField and Keyboard

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtfEmail resignFirstResponder];
    [self.txtfTitle resignFirstResponder];
    [self.txtfLastName resignFirstResponder];
    [self.txtfUniversity resignFirstResponder];
    [self.txtfDescription resignFirstResponder];
    [self.txtfFirstName resignFirstResponder];
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

- (IBAction)btnRegisterPressed:(id)sender {
    
    
    NSDictionary *parameters = @{@"email" : self.txtfEmail.text,
                                 @"password" : self.txtfPassword.text, @"firstname" : self.txtfFirstName.text, @"lastname" : self.txtfLastName.text, @"description" : self.txtfDescription.text, @"title" : self.txtfTitle.text, @"university" : self.txtfUniversity.text, @"userId" : @"filip1233242342"};
    
    [[HttpManager sharedInstance] registerUserWithParameters:parameters successHandler:^(NSDictionary *myInfo) {
        
        NSLog(@"REGISTRATION successHandler");
        
        [[HttpManager sharedInstance] loginUserWithEmail:self.txtfEmail.text password:self.txtfPassword.text successHandler:^(NSDictionary *myInfo) {
            
            NSLog(@"LOGIN successHandler");
            
            [[HttpManager sharedInstance] getUserWithEmail:self.txtfEmail.text successHandler:^(NSDictionary *userInfo) {
                NSLog(@"GET_USER successHandler");
                
                [LecturerManager sharedInstance].userProfile = [[LecturerUser alloc] init];
                [[LecturerManager sharedInstance].userProfile createWithDictionary:userInfo];
                
                [self performSegueWithIdentifier:@"RegistrationToActivationSegue" sender:nil];
                
            } failureHandler:^(NSError *error) {
                
                NSLog(@"GET_USER failureHandler");
            }];
            
            
        } failureHandler:^(NSError *error) {
            
            NSLog(@"LOGIN failureHandler");
        }];
        
        
    } failureHandler:^(NSError *error) {
        
        NSLog(@"REGISTRATION failureHandler");
    }];
    
}

- (IBAction)btnBackPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
