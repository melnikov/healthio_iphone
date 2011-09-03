//
//  ProviderEditTable.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProviderObject;

@interface ProviderEditTable : UIViewController <UITableViewDelegate,UITableViewDataSource> {
	
	int index;
	ProviderObject * editableObject;
	IBOutlet UITableView * table;
	NSMutableArray * source;
}

@property (nonatomic) int index;
@property (nonatomic, retain) ProviderObject *editableObject;
- (id)initWithIndex:(int)anIndex editableObject:(NSMutableArray*)anEditableObject;

@end
