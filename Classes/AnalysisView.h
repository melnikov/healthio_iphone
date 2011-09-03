//
//  AnalysisView.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AnalysisView : UIViewController {

	IBOutlet UITableView * table;
	
}
-(IBAction) didClickLogoutButton:(id)sender;

@property (nonatomic,retain) UITableView * table;
@end
