//
//  PhoneEmail.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Autocomplete;

@interface PhoneEmail :  UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
	UITableView * suggestTable;
	NSString * tmpName;
	UITextField * cityField;
	NSString * tmpDescription;
	NSArray * suggestions;
	Autocomplete	*autocomplete;
}

@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, retain) UITextField * cityField;

@property (nonatomic, retain) UITableView * suggestTable;

@property (nonatomic, retain) NSString *tmpName;
@property (nonatomic, retain) NSString *tmpDescription;


@end
