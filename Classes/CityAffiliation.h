//
//  CityAffiliation.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProviderObject;
@class Autocomplete;

@interface CityAffiliation :  UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
	UITableView * suggestTable;
	ProviderObject * editable;	
	NSString * tmpName;
	UITextField * cityField;
	NSString * tmpDescription;
	NSArray * suggestions;
	Autocomplete	*autocomplete;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) ProviderObject *editable;

@property (nonatomic, retain) UITextField * cityField;

@property (nonatomic, retain) UITableView * suggestTable;

@property (nonatomic, retain) NSString *tmpName;
@property (nonatomic, retain) NSString *tmpDescription;

- (id)initWithEditable:(ProviderObject*)anEditable;

@end
