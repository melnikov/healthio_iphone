//
//  ProvidersTableCell.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "ProvidersTableCell.h"
#import "ProviderObject.h"
#import "HealthIOAppDelegate.h"

@implementation ProvidersTableCell

@synthesize lbName;
@synthesize lbDesc;
@synthesize lbUpdate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void) setData:(ProviderObject*) data{
	
	lbName.text = data.name;
	
	CGSize nameSize = [data.name sizeWithFont:[lbName font]];
	
	float offset = nameSize.width+20;
	
	lbDesc.frame = CGRectMake(offset+10, 5, 285-offset, 20);
	
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate*) [[UIApplication sharedApplication]delegate];
	
	lbDesc.text = [NSString stringWithFormat:@"(%@)", [delegate.providersSpecialties objectAtIndex:data.specialty]];
	
	lbUpdate.text = [NSString stringWithFormat:@"%@, %@",data.affiliation,data.cityName];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	
    [lbName release];
    lbName = nil;
    [lbDesc release];
    lbDesc = nil;
    [lbUpdate release];
    lbUpdate = nil;
    [super dealloc];
}


@end
