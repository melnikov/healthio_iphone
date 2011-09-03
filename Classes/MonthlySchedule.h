//
//  MonthlySchedule.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IndicationsObject;

@interface MonthlySchedule : UIViewController {
    IBOutlet UITableView * table1;
    IndicationsObject * editable;
    int repeatType;
    NSDateComponents * dateObject;
}
- (id)initWithEditable:(IndicationsObject*)anEditable repeatType:(int)aRepeatType preset:(NSDateComponents*) anPreset;
@property (nonatomic,retain) IBOutlet UITableView * table1;
@property (nonatomic, retain) IndicationsObject *editable;
@property (nonatomic, retain) NSDateComponents * preset;
@property (nonatomic) int repeatType;
@end
