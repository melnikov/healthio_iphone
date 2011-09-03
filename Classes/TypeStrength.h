//
//  TypeStrength.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TreatmentObject;

@interface TypeStrength : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
	TreatmentObject * editable;	
	NSString * tmpName;
	NSString * tmpDescription;
	UITextField * strengthField;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UITextField *strengthField;

@property (nonatomic, retain) TreatmentObject *editable;

@property (nonatomic, retain) NSString *tmpName;
@property (nonatomic, retain) NSString *tmpDescription;

- (id)initWithEditable:(TreatmentObject *)anEditable;

@end
