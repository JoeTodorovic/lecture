//
//  LecturerHomeViewController.m
//  lecture
//
//  Created by Dusan Todorovic on 12/7/16.
//  Copyright © 2016 joeTod. All rights reserved.
//

#import "LecturerHomeViewController.h"

@interface LecturerHomeViewController (){
    
    Lecture *selectedLecture;
}

@end

@implementation LecturerHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tvLectures.delegate = self;
    self.tvLectures.dataSource = self;
    self.tvLectures.allowsMultipleSelectionDuringEditing = NO;
    
    self.activityIndicator.hidden = YES;
    
    
    if ([LecturerManager sharedInstance].loginToLectureFlag) {
        
        LectureViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LectureViewSID"];
        vc.lecture = [[LecturerManager sharedInstance] getLectureWithUniqueId:[LecturerManager sharedInstance].runningLectureUniqueId];
        vc.newLectureFlag = NO;
        [self.navigationController pushViewController:vc animated:NO];
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[LecturerManager sharedInstance].lectures count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LectureTableViewCell *cellLecture = [tableView dequeueReusableCellWithIdentifier:@"LectureCell"];
    
    Lecture *lecture = [[LecturerManager sharedInstance].lectures objectAtIndex:indexPath.row];
    
    cellLecture.textLabel.text = lecture.name;
    cellLecture.detailTextLabel.text = lecture.lectureDescription;
    
    return cellLecture;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedLecture = [[LecturerManager sharedInstance].lectures objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"HomeToLectureSegue" sender:self];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        [[HttpManager sharedInstance] deleteLectureWithId:((Lecture *)[[LecturerManager sharedInstance].lectures objectAtIndex:indexPath.row]).lectureId successHandler:^{
            
            [[LecturerManager sharedInstance].lectures removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tvLectures reloadData];
            
        } failureHandler:^(NSError *error) {
            
        }];
    }
}



- (IBAction)bbiCreateLecturePressed:(id)sender {
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"HomeToLectureSegue"]){
        LectureViewController *vc = segue.destinationViewController;
        vc.lecture = selectedLecture;
        vc.newLectureFlag = NO;
        
    }
}



@end
