//
//  OnceSchedule.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndicationsObject;

@interface OnceSchedule : UIViewController{
    IndicationsObject * editable;
    int repeatType;
NSMutableArray * tempRepeat;
}
- (id)initWithEditable:(IndicationsObject*)anEditable repeatType:(int)aRepeatType;
-(IBAction) didChangePickerValue:(UIDatePicker*) picker;
@property (nonatomic,retain) IBOutlet UITableView * table1;
@property (nonatomic, retain) IndicationsObject *editable;
@property (nonatomic) int repeatType;
@property (nonatomic,retain) NSMutableArray * tempRepeat;

@end
