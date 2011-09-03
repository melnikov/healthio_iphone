//
//  NameDescription.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndicationsObject;

@interface NameDescription : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
	IndicationsObject * editable;	
	NSString * tmpName;
	NSString * tmpDescription;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IndicationsObject *editable;

@property (nonatomic, retain) NSString *tmpName;
@property (nonatomic, retain) NSString *tmpDescription;

- (id)initWithEditable:(IndicationsObject*)anEditable;

@end
