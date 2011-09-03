//
//  MedicalSystem.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TreatmentObject;


@interface MedicalSystem : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
	TreatmentObject * editable;	
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) TreatmentObject *editable;

- (id)initWithEditable:(TreatmentObject *)anEditable;

@end
