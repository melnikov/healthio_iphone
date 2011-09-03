//
//  YearlySchedule.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndicationsObject;

@interface YearlySchedule : UIViewController {
    IBOutlet UITableView * table1;
    IndicationsObject * editable;
    int repeatType;
}
- (id)initWithEditable:(IndicationsObject*)anEditable repeatType:(int)aRepeatType;
@property (nonatomic,retain) UITableView * table1;
@property (nonatomic, retain) IndicationsObject *editable;
@property (nonatomic) int repeatType;
@end
