//
//  Birth.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/26/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Height : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	IBOutlet UITableView * table;
    NSArray * source;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet NSArray * source;
@end
