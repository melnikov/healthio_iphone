//
//  ProfileEditTableView.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileObject;


@interface ProfileEditTableView : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	ProfileObject * editableObject;
	IBOutlet UITableView * table;
	int index;
    
    NSArray * ages;
    NSArray * heights;
    NSArray * weights;
    NSArray * smokers;
    NSArray * drinkers;
    NSArray * genders;    
    NSArray * alerts;
}

-(IBAction) didClickSaveButton:(id)sender;

@property (nonatomic,readwrite) int index;

@property (nonatomic, retain) NSArray *ages;
@property (nonatomic, retain) NSArray *alerts;
@property (nonatomic, retain) NSArray *heights;
@property (nonatomic, retain) NSArray *weights;
@property (nonatomic, retain) NSArray *smokers;
@property (nonatomic, retain) NSArray *drinkers;
@property (nonatomic, retain) NSArray *genders;

@end
