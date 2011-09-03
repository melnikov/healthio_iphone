//
//  StartEnd.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndicationsObject;

@interface StartEnd : UIViewController <UITableViewDelegate,UITableViewDataSource>{
	IBOutlet UIDatePicker * datePicker;
	UITableView * table;
	IndicationsObject * editable;
	int dateSelector;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IndicationsObject *editable;

@property (readwrite) int dateSelector;
- (id)initWithEditable:(IndicationsObject*)anEditable;

-(IBAction) didChangePickerValue:(UIDatePicker *) sender;

@end
