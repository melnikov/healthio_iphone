//
//  IndicationsTableView.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IndicationsTableView : UITableViewController <UITableViewDelegate> {
	IBOutlet UIView * header1;
	IBOutlet UIView * header2;
	IBOutlet UIView * header3;
}
-(IBAction) didClickLogoutButton:(id)sender;

@property (nonatomic, retain) IBOutlet UIView *header1;
@property (nonatomic, retain) IBOutlet UIView *header2;
@property (nonatomic, retain) IBOutlet UIView *header3;

@end
