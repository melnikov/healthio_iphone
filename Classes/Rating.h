//
//  Rating.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProviderObject;

@interface Rating :UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
	UILabel * sliderLabel;
	ProviderObject * editable;	
	NSString * tmpName;
	NSString * tmpDescription;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) ProviderObject *editable;

@property (nonatomic,retain) UILabel * sliderLabel;

@property (nonatomic, retain) NSString *tmpName;
@property (nonatomic, retain) NSString *tmpDescription;

- (id)initWithEditable:(ProviderObject*)anEditable;

@end
