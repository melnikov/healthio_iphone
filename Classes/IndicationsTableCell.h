//
//  TreatmentsTableCell.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndicationsObject;

@interface IndicationsTableCell : UITableViewCell {
	IBOutlet UILabel * lbName;
	IBOutlet UILabel  * lbDesc;
	IBOutlet UILabel  * lbUpdate;
	

}

-(void) setData:(IndicationsObject*) data;
-(void) setDataWithRepeat:(IndicationsObject*) data;

@property (nonatomic, retain) IBOutlet UILabel *lbName;
@property (nonatomic, retain) IBOutlet UILabel *lbDesc;
@property (nonatomic, retain) IBOutlet UILabel *lbUpdate;




@end
