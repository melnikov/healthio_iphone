//
//  HealthIOAppDelegate.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "ClearDBAppClient.h"

@class TreatmentObject;
@class IndicationsObject;
@class ProfileObject;
@interface HealthIOAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate,UIAlertViewDelegate> {
    
    int user_id;
    
    UIWindow *window;
    UITabBarController *tabBarController;
	
	NSMutableArray * indicationsConditions;
	NSMutableArray * indicationsSymptoms;
	NSMutableArray * indicationsTestResults;
	
	NSMutableArray * treatmentMedication;
	NSMutableArray * treatmentTherapies;
	NSMutableArray * treatmentFood;
	
	NSMutableArray * providersPhysicians;
	NSMutableArray * providersTherapists;
	NSMutableArray * providersOthers;
	
	NSMutableArray * questions;
	
	
    UILocalNotification * lastNotification;
    
    ClearDBAppClient * client;
    
	sqlite3 * database;
	sqlite3_stmt *statement;

    
	ProfileObject * profile;
	
	NSArray * treatmentTypes;
	NSArray * medicalTypes;
	NSArray * providersSpecialties;
	NSArray * cityList;
	
    UIViewController * summaryView;
	
}

@property (nonatomic) sqlite3 * database;
@property (nonatomic) sqlite3_stmt *statement;

@property (nonatomic) ClearDBAppClient * client;

@property (nonatomic) ProfileObject * profile;

@property (nonatomic,retain) UIViewController * summaryView;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) NSArray * treatmentTypes;
@property (nonatomic, retain) NSArray * medicalTypes;
@property (nonatomic, retain) NSArray * providersSpecialties;
@property (nonatomic, retain) NSArray * cityList;

@property (nonatomic, retain) NSMutableArray *indicationsConditions;
@property (nonatomic, retain) NSMutableArray *indicationsSymptoms;
@property (nonatomic, retain) NSMutableArray *indicationsTestResults;

@property (nonatomic, retain) NSMutableArray *treatmentMedication;
@property (nonatomic, retain) NSMutableArray *treatmentTherapies;
@property (nonatomic, retain) NSMutableArray *treatmentFood;

@property (nonatomic, retain) NSMutableArray *providersPhysicians;
@property (nonatomic, retain) NSMutableArray *providersTherapists;
@property (nonatomic, retain) NSMutableArray *providersOthers;

@property (nonatomic, retain) NSMutableArray * questions;

@property (nonatomic) int user_id;

-(IndicationsObject *) getNextTreatment;
+(NSDate *) getNextOccurence:(IndicationsObject *)candidate;

-(void) rescheduleNotifications;
-(void) doLogout;
@end
