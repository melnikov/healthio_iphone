//
//  TreatmentsTableCell.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "IndicationsTableCell.h"
#import "IndicationsObject.h"


@implementation IndicationsTableCell

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

-(void) setDataWithRepeat:(IndicationsObject*) data{
	[self setData:data];
	
       //*************
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, hh:mm a"];
    
    NSString * repTime = [formatter stringFromDate:data.startDate];
    
    NSArray * repeatItems = [[NSArray alloc] initWithObjects:
                             [NSString stringWithFormat:@"Once"],
                             [NSString stringWithFormat:@"Daily"],
                             [NSString stringWithFormat:@"Weekly"],
                             [NSString stringWithFormat:@"Monthly"],
                             [NSString stringWithFormat:@"Yearly"],
                             nil];
    
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    NSDateComponents* comp = [cal components:(NSWeekdayCalendarUnit | NSMonthCalendarUnit| NSDayCalendarUnit) fromDate:data.startDate]; 
    if ([data.repeatTimes count]>0)
        comp = [data.repeatTimes objectAtIndex:0];
    
    NSArray * weekdays = [[NSArray alloc]initWithObjects:
                          [NSString stringWithFormat:@"Monday"],
                          [NSString stringWithFormat:@"Tuesday"],
                          [NSString stringWithFormat:@"Wednesday"],
                          [NSString stringWithFormat:@"Thursday"],
                          [NSString stringWithFormat:@"Friday"],
                          [NSString stringWithFormat:@"Saturday"],
                          [NSString stringWithFormat:@"Sunday"],
                          nil];
    
    
    NSArray * months = [[NSArray alloc]initWithObjects:
                        [NSString stringWithFormat:@"---"],
                        [NSString stringWithFormat:@"January"],
                        [NSString stringWithFormat:@"February"],
                        [NSString stringWithFormat:@"March"],
                        [NSString stringWithFormat:@"April"],
                        [NSString stringWithFormat:@"May"],
                        [NSString stringWithFormat:@"June"],
                        [NSString stringWithFormat:@"July"],
                        [NSString stringWithFormat:@"August"],
                        [NSString stringWithFormat:@"September"],
                        [NSString stringWithFormat:@"October"],
                        [NSString stringWithFormat:@"November"],
                        [NSString stringWithFormat:@"December"],
                        
                        
                        nil];
    int c = 0;
    
    switch (data.repeatType) {
        case 2:
            c=1;
            break;
        case 4:
            c=2;
            break;
        case 8:
            c=3;
            break;
        case 16:
            c=4;
            break;
        case 32:
            c=5;
            break;
        case 64:
            c=6;
            break;
        default:
            break;
    }
    
    switch (c) {
        case 0://once
            if (data.repeatType == 0 && [data.repeatTimes count]>0)
                [lbUpdate setText:[NSString stringWithFormat:@"%@ on %@",[repeatItems objectAtIndex:c],
                                               [formatter stringFromDate:[cal dateFromComponents:[data.repeatTimes objectAtIndex:0]]]
                                               
                                               ]];
            else
                [lbUpdate setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
            
            break;
        case 1://daily
            if (data.repeatType == 2 && [data.repeatTimes count]>0)
                [lbUpdate setText:[NSString stringWithFormat:@"%@, %d time(s) per day",[repeatItems objectAtIndex:c],[data.repeatTimes count]]];
            else
                [lbUpdate setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
            break;
        case 2://weekly
            if (data.repeatType == 4 && [data.repeatTimes count]>0)
                [lbUpdate setText:[NSString stringWithFormat:@"%@, %d time(s) on %@",[repeatItems objectAtIndex:c],
                                               [data.repeatTimes count],
                                               [weekdays objectAtIndex:[comp weekday]]]];
            else
                [lbUpdate setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
            break;
        case 3://montly
            if (data.repeatType == 8 && [data.repeatTimes count]>0)
                [lbUpdate setText:[NSString stringWithFormat:@"%@, %d time(s) every month on %d",
                                               [repeatItems objectAtIndex:c],
                                               [data.repeatTimes count],
                                               [comp day]+1
                                               ]];
            else
                [lbUpdate setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
            break;
        case 4://yearly
            
            
            if (data.repeatType == 16 && [data.repeatTimes count]>0)
                [lbUpdate setText:[NSString stringWithFormat:@"Yearly, %d time(s) on %@, %d",
                                               [data.repeatTimes count],
                                               [months objectAtIndex:[comp month]+1],
                                               [comp day]+1
                                               ]];
            else
                [lbUpdate setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
            
        default:
            break;
    }
    
    
    //*******************
    
     
    [weekdays release];
    [months release];
    
    
    
    [repeatItems release];


    
    
}

-(void) setData:(IndicationsObject*) data{
	
	lbName.text = data.name;
	lbName.textColor = [UIColor colorWithRed:0.180 green:0.251 blue:0.078 alpha:1.0];
	
	
	CGSize nameSize = [data.name sizeWithFont:[lbName font]];
	
	float offset = nameSize.width;
	
	lbDesc.frame = CGRectMake(offset+10, 16, 285-offset, 20);
	lbDesc.textColor = [UIColor colorWithRed:0.180 green:0.251 blue:0.078 alpha:1.0];
	
	if (data.severity>=0)
		lbDesc.text = [NSString stringWithFormat:@"(Severity %d%%) %@", data.severity, data.description];
	else
	{
		
		if (![data.description isEqualToString:@""])
			lbDesc.text = [NSString stringWithFormat:@"(%@)", data.description];
		else 
			lbDesc.text = @"";
		
	}
	if (data.lastUpdateDate==nil)
		lbUpdate.text = @"";
	else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"dd MMM yyyy, hh:mm a"];
		lbUpdate.text = [NSString stringWithFormat:@"Last updated: %@", [formatter stringFromDate:data.lastUpdateDate]];
		[formatter release];
	}
	lbUpdate.textColor = [UIColor colorWithRed:0.180 green:0.251 blue:0.078 alpha:1.0];
	
	
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
