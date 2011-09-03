//
//  YearlySchedule.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "YearlySchedule.h"
#import "MonthlySchedule.h"
#import "IndicationsObject.h"

@implementation YearlySchedule

@synthesize table1;
@synthesize editable;
@synthesize repeatType;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithEditable:(IndicationsObject*)anEditable repeatType:(int)aRepeatType 
{
    self = [super init];
    if (self) {
        editable = anEditable;
        repeatType = aRepeatType;
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
    
    NSArray * months = [NSArray arrayWithObjects:
                        @"Every January",
                        @"Every February",
                        @"Every March",
                        @"Every April",
                        @"Every May",
                        @"Every June",
                        @"Every July",
                        @"Every August",
                        @"Every September",
                        @"Every October",
                        @"Every November",
                        @"Every December",
                        nil];
    
    switch (tableView.tag) {
        case 0:
            
            [cell.textLabel setText:[months objectAtIndex:indexPath.row]];
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
    
    NSDateComponents * preset = [[[NSCalendar currentCalendar]components:(NSYearCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[NSDate date]] retain];
    [preset setMonth:indexPath.row];
    NSLog(@"Setting month: %d",[preset month]);
    MonthlySchedule * ds = [[MonthlySchedule alloc]initWithEditable:editable repeatType:repeatType preset:preset];
    
    [self.navigationController pushViewController:ds animated:YES];
    [ds release];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (tableView.tag) {
        case 0:
            return 12;
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
    self.title = @"Month";
    [super viewDidLoad];
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
