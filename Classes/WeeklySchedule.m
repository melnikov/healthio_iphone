
//
//  WeeklySchedule.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "WeeklySchedule.h"
#import "DailySchedule.h"
#import <QuartzCore/QuartzCore.h>
#import "IndicationsObject.h"


@implementation WeeklySchedule
@synthesize table1;
@synthesize editable;
@synthesize repeatType;
@synthesize preset;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithEditable:(IndicationsObject*)anEditable repeatType:(int)aRepeatType preset:(NSDateComponents*) anPreset{
    self = [super init];
    if (self) {
        editable = anEditable;
        repeatType = aRepeatType;
        if (preset)
            preset = [anPreset retain];
        else
        {
            NSCalendar * cal = [NSCalendar currentCalendar];
            preset = [[cal components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[NSDate date]]retain ];
            
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark table function

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"WeeklyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray * weekdays = [NSArray arrayWithObjects:
                          @"Monday",
                          @"Tuesday",
                          @"Wednesday",
                          @"Thursday",
                          @"Friday",
                          @"Saturday",
                          @"Sunday"
                          , nil];
    
    NSArray * times = [NSArray arrayWithObjects:
                       @"0:00 am",
                       @"1:00 am",
                       @"2:00 am",
                       @"3:00 am",
                       @"4:00 am",
                       @"5:00 am",
                       @"6:00 am",
                       @"7:00 am",
                       @"8:00 am",
                       @"9:00 am",
                       @"10:00 am",
                       @"11:00 am",
                       @"12:00 am",
                       @"1:00 pm",
                       @"2:00 pm",
                       @"3:00 pm",
                       @"4:00 pm",
                       @"5:00 pm",
                       @"6:00 pm",
                       @"7:00 pm",
                       @"8:00 pm",
                       @"9:00 pm",
                       @"10:00 pm",
                       @"11:00 pm",
                       nil];
    
    switch (tableView.tag) {
        case 0:
            
            [cell.textLabel setText:[weekdays objectAtIndex:indexPath.row]];
            break;
        case 1:
            [cell.textLabel setText:[times objectAtIndex:indexPath.row]];
            break;
            
        default:
            break;
    }
    
    //   [times release];
    //    [weekdays release];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   // cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
//
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    switch (section) {
//        case 0:
//            return @"Please select days";
//            break;
//        case 1:
//            return @"Please select times";
//        default:
//            break;
//    }  
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [preset setWeekday:indexPath.row];
    DailySchedule * ds = [[DailySchedule alloc]initWithEditable:editable repeatType:repeatType preset:preset];
    [self.navigationController pushViewController:ds animated:YES];
    [ds release];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (tableView.tag) {
        case 0:
            return 7;
            break;
        case 1:
            return 24;
        default:
            break;
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Day";
    table1.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
	self.view.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
