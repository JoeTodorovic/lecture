//
//  ActivationViewController.h
//  lecture
//
//  Created by Dusan Todorovic on 8/10/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivationViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *tfActivationCode;
@property (strong, nonatomic) IBOutlet UIButton *btnActivate;

- (IBAction)btnActivatePressed:(id)sender;

@end
