//
//  TreatmentsView.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TreatmentsView : UITableViewController <UITableViewDelegate> {
	IBOutlet UIView * header1;
	IBOutlet UIView * header2;
	IBOutlet UIView * header3;
}

-(IBAction) didClickLogoutButton:(id)sender;
@end
