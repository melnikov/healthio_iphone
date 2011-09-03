//
//  TreatmentEditTable.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClearDBAppClient.h"


@class TreatmentObject;

@interface TreatmentEditTable: UIViewController <UITableViewDelegate,UITableViewDataSource> {
	
	int index;
	TreatmentObject * editableObject;
	NSMutableArray * source;
	IBOutlet UITableView * table;
    ClearDBAppClient * client;

}

@property (nonatomic) int index;
@property (nonatomic, retain) TreatmentObject *editableObject;
- (id)initWithIndex:(int)anIndex editableObject:(NSMutableArray*)anEditableObject;

@end
