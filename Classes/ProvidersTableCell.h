//
//  ProvidersTableCell.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProviderObject;

@interface ProvidersTableCell : UITableViewCell {
	IBOutlet UILabel * lbName;
	IBOutlet UILabel  * lbDesc;
	IBOutlet UILabel  * lbUpdate;
	
	
}

-(void) setData:(ProviderObject*) data;

@property (nonatomic, retain) IBOutlet UILabel *lbName;
@property (nonatomic, retain) IBOutlet UILabel *lbDesc;
@property (nonatomic, retain) IBOutlet UILabel *lbUpdate;




@end
