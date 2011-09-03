//
//  DailySchedule.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "DailySchedule.h"
#import "IndicationsObject.h"
#import <QuartzCore/QuartzCore.h>
#import "HealthIOAppDelegate.h"
@implementation DailySchedule
@synthesize table1;
@synthesize editable;
@synthesize repeatType;
@synthesize preset;
@synthesize tempRepeat;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithEditable:(IndicationsObject*)anEditable repeatType:(int)aRepeatType preset:(NSDateComponents*) anPreset{
    self = [super init];
    if (self) {
        editable = anEditable;
        repeatType = aRepeatType;
        if (anPreset)
            self.preset = [anPreset retain];
        else
        {
            NSCalendar * cal = [NSCalendar currentCalendar];
            self.preset = [[cal components:(NSYearCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[NSDate date]]retain ];
            
        }
    }
    if ([anEditable.repeatTimes count]>0 && anEditable.repeatType == aRepeatType){
        self.tempRepeat = [[NSMutableArray alloc] initWithArray:anEditable.repeatTimes];
        for (int j=0; j<[tempRepeat count]; j++) {
            [((NSDateComponents *)[tempRepeat objectAtIndex:j]) setDay:[anPreset day]];
            [((NSDateComponents *)[tempRepeat objectAtIndex:j]) setWeekday:[anPreset weekday]];
            [((NSDateComponents *)[tempRepeat objectAtIndex:j]) setMonth:[anPreset month]];
        }
    }
    else
        self.tempRepeat = [NSMutableArray arrayWithCapacity:0];
    
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
    static NSString *CellIdentifier = @"Cell";
    
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
    
    
    int minutes = 0;
    int hours = indexPath.row;
    
    bool found = false;
    for (int j=0;j<[tempRepeat count];j++)
    {
        NSDateComponents *tpm = [self.tempRepeat objectAtIndex:j];
        if ([tpm hour]==hours)
        {
            found = true;
            break;
        }
    }
    
    if (found)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    //   [times release];
    //    [weekdays release];
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
    NSCalendar * cal = [NSCalendar currentCalendar];
    
    int minutes = 0;
    int hours = indexPath.row;
    
    bool found = false;
    for (int j=0;j<[tempRepeat count];j++)
    {
        NSDateComponents *tpm = [tempRepeat objectAtIndex:j];
        if ([tpm minute]==minutes && [tpm hour]==hours)
        {
            [tempRepeat removeObjectAtIndex:j];
            found = true;
        }
    }
    
    if (!found)
    {
        NSDateComponents * tpm1 = [preset copy];        
        [tpm1 setMinute:minutes];
        [tpm1 setHour:hours];
        [self.tempRepeat addObject:tpm1];
    }
    
    [table1 reloadData];
    
    for (int j=0;j<[tempRepeat count];j++) 
        NSLog(@"Month = %d, day = %d, hour = %d",[((NSDateComponents *)[self.tempRepeat objectAtIndex:j]) month], [((NSDateComponents *)[self.tempRepeat objectAtIndex:j]) day],[((NSDateComponents *)[self.tempRepeat objectAtIndex:j]) hour]);
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

-(IBAction) didClickSaveButton:(id)sender{
    
    if ([self.tempRepeat count]==0)
    {
        UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please select at least one time slot" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [av release];
        return;
        
    }
    editable.repeatTimes = [self.tempRepeat retain];
    editable.repeatType = repeatType;
    
    editable.startDate = [NSDate date];
    editable.endDate = nil;
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
    [self.navigationController popToViewController:delegate.summaryView animated:YES];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Time";
    //table1.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
	self.view.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
    
    table1.layer.cornerRadius = 8.0;
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(didClickSaveButton:)];
	[self.navigationItem setRightBarButtonItem:saveButton];
	[saveButton release];
    
    // Do any additional setup after loading the view from its nib.
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
