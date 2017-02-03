//
//  BadgeSegmentedControl.h
//  lecture
//
//  Created by Dusan Todorovic on 1/24/17.
//  Copyright © 2017 joeTod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeSegmentedControl : UISegmentedControl

- (void)setBadge:(NSString *)badge
forSegmentAtIndex:(NSUInteger)index;

@end
