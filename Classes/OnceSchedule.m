//
//  OnceSchedule.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/21/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "OnceSchedule.h"
#import "IndicationsObject.h"
#import "HealthIOAppDelegate.h"

@implementation OnceSchedule

@synthesize editable;
@synthesize repeatType;
@synthesize tempRepeat;

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

-(IBAction) didChangePickerValue:(UIDatePicker*) picker{
    NSCalendar * cal = [NSCalendar currentCalendar];
    [tempRepeat removeAllObjects];
    
    NSDateComponents * components = [cal components:(NSYearCalendarUnit| NSDayCalendarUnit|NSMonthCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:picker.date];
    [tempRepeat addObject:[components retain]];
    
 //   editable.rep
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
    editable.startDate = [[NSCalendar currentCalendar] dateFromComponents:[self.tempRepeat objectAtIndex:0]];
    editable.endDate = nil;
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
    [self.navigationController popToViewController:delegate.summaryView animated:YES];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Date/Time";
    self.view.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];

    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(didClickSaveButton:)];
	[self.navigationItem setRightBarButtonItem:saveButton];
	[saveButton release];
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
