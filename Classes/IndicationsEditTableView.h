//
//  IndicationsEditTableView.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndicationsObject;

@interface IndicationsEditTableView : UIViewController <UITableViewDelegate,UITableViewDataSource> {

	int index;
	IndicationsObject * editableObject;
	NSMutableArray * source;
	IBOutlet UITableView * table;
}

@property (nonatomic) int index;
@property (nonatomic, assign) NSMutableArray * source;
@property (nonatomic, retain) IndicationsObject *editableObject;
- (id)initWithIndex:(int)anIndex editableObject:(NSMutableArray*)anEditableObject;

@end
