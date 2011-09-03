//
//  NameSpecialty.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProviderObject;

@interface NameSpecialty : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
	ProviderObject * editable;	

	UITextField * nameField;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UITextField *nameField;

@property (nonatomic, retain) ProviderObject *editable;



- (id)initWithEditable:(ProviderObject *)anEditable;

@end
