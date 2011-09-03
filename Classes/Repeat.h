//
//  Repeat.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndicationsObject;

@interface Repeat : UIViewController {

	IBOutlet UITableView * table;
	IBOutlet UIDatePicker * picker;
	IndicationsObject * editable;
	
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIDatePicker *picker;
@property (nonatomic, retain) IndicationsObject *editable;
- (id)initWithEditable:(IndicationsObject*)anEditable;

-(IBAction) didChangePickerValue:(UIDatePicker *) sender;

@end
