//
//  BadgeSegmentedControl.m
//  lecture
//
//  Created by Dusan Todorovic on 1/24/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import "BadgeSegmentedControl.h"

@implementation BadgeSegmentedControl{
    
    UIView *badgeView;
}

- (void)setBadge:(NSString *)badge
forSegmentAtIndex:(NSUInteger)index
{
    
    // If empty we finished
    if (![badge isEqualToString:@"0"] && (badge != nil)){
        // Configure
        
        if (badgeView == nil) {
            badgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15.0, 15.0)];
            [badgeView setBackgroundColor:[UIColor redColor]];
            badgeView.layer.cornerRadius = 15.0f/2;
            badgeView.clipsToBounds = YES;
        }
        
        UILabel *badgeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        [badgeView addSubview:badgeLbl];
        badgeLbl.textAlignment = NSTextAlignmentCenter;
        badgeLbl.text = badge;
        badgeLbl.textColor = [UIColor whiteColor];
        [badgeLbl setFont:[UIFont systemFontOfSize:11]];
        
        
        // Place it
        CGRect frame = badgeView.frame;
        frame.origin = self.frame.origin;
        frame.origin.x += (self.frame.size.width / self.numberOfSegments) * (index + 1);          // Just outside
        frame.origin.x -= badgeView.frame.size.width + 2.0;                                       // Pull it in
        frame.origin.x -= MAX(0.0,
                              CGRectGetMaxX(frame) - CGRectGetMaxX(self.superview.bounds)); // Not too much to the right!
        frame.origin.y -= 10.0;                                                             // Just on top
        frame.origin.y = MAX(2.0,
                             frame.origin.y);                                               // Not too high!
        badgeView.frame = frame;
        
        [self.superview addSubview:badgeView];
    }
    else{
        [badgeView removeFromSuperview];
        badgeView = nil;
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
