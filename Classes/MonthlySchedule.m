//
//  MonthlySchedule.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "DailySchedule.h"
#import "MonthlySchedule.h"
#import "IndicationsObject.h"

@implementation MonthlySchedule
@synthesize table1;

@synthesize editable;
@synthesize repeatType;

@synthesize preset;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithEditable:(IndicationsObject*)anEditable repeatType:(int)aRepeatType preset:(NSDateComponents*) anPreset;{
    self = [super init];
    if (self) {
        editable = anEditable;
        repeatType = aRepeatType;
        if (anPreset)
            preset = [anPreset retain];
        else
        {
            NSCalendar * cal = [NSCalendar currentCalendar];
            preset = [[cal components:(NSYearCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[NSDate date]]retain ];
        
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
    
    NSArray * months = [NSArray arrayWithObjects:
                        @"On 1st",
                        @"On 2nd",
                        @"On 3rd",
                        @"On 4th",
                        @"On 5th",
                        @"On 6th",
                        @"On 7th",
                        @"On 8th",
                        @"On 9th",
                        @"On 10th",
                        @"On 11th",
                        @"On 12th",
                        @"On 13th",
                        @"On 14th",
                        @"On 15th",
                        @"On 16th",
                        @"On 17th",
                        @"On 18th",
                        @"On 19th",
                        @"On 20th",
                        @"On 21st",
                        @"On 22nd",
                        @"On 23rd",
                        @"On 24th",
                        @"On 25th",
                        @"On 26th",
                        @"On 27th",
                        @"On 28th",
                        @"On last day of the month",
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
   
    [preset setDay:indexPath.row];
    DailySchedule * ds = [[DailySchedule alloc]initWithEditable:editable repeatType:repeatType preset:preset];
    
    [self.navigationController pushViewController:ds animated:YES];
    [ds release];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (tableView.tag) {
        case 0:
            return 29;
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
