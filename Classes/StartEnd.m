//
//  StartEnd.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "StartEnd.h"
#import "IndicationsObject.h"


@implementation StartEnd

@synthesize datePicker;
@synthesize editable;
@synthesize table;
@synthesize dateSelector;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithEditable:(IndicationsObject*)anEditable  
{
    self = [super init];
    if (self) {
        editable = [anEditable retain];
    }
	dateSelector = 0;
table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 151) style:UITableViewStyleGrouped];
[table setDelegate:self];
[table setDataSource:self];
	
[self.view addSubview:table];
	[table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
	
	[datePicker setDate:editable.startDate animated:YES];
//	[datePicker setMinimumDate:[NSDate date]];
	
return self;
}

#pragma mark Table functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
    static NSString *CellIdentifier = @"IndicationsStartEndCell";
	
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//UITextField * tf = [[UITextField alloc]initWithFrame:CGRectMake(25, 10, 280, 20)];
	//tf.delegate = self;
	//[tf addTarget:self action:@selector(textFieldDidChangeEditing:) forControlEvents:UIControlEventEditingChanged];
	
	if (!cell) 
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
	[cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd MMM yyyy"];
	UISwitch *us;
	switch (indexPath.row) {
		case 0://name
			[cell.textLabel setText:@"Start date"];
			
			//[datePicker setMinimumDate:[editable.startDate earlierDate:[NSDate date]]];
			[datePicker setMinimumDate:nil];
			
			NSString *stringFromDate = [formatter stringFromDate:editable.startDate];
						
			[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",stringFromDate]];
			
			break;
		case 1:
            
            us = [[UISwitch alloc]init];
            [us addTarget:self action:@selector(didSwitchEndDate:) forControlEvents:UIControlEventValueChanged];
            if (editable.endDate)
                us.on = TRUE;
            else
                us.on = FALSE;
            /*if (!editable.endDate)
                datePicker.enabled = FALSE;
            else
                datePicker.enabled = TRUE;*/
			//[datePicker setMinimumDate:[editable.startDate laterDate:[NSDate date]]];
			[cell.textLabel setText:@"End date"];
			stringFromDate = [formatter stringFromDate:editable.endDate];
            if (!stringFromDate)
                stringFromDate = @"not set";
			[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",stringFromDate]];
            [cell setAccessoryView:us];
            [us release];
			break;
		default:
			break;
	}
	
	[formatter release];

	
	//IndicationsObject * cellObject = [[datasource objectAtIndex:indexPath.row]retain];
	//[cell setData:cellObject];
	
	
	
    // Configure the cell...
    
    return cell;
}

-(void) didSwitchEndDate:(UISwitch *)sender
{

    if (sender.on){
        editable.endDate = [editable.startDate retain];
        datePicker.enabled = YES;
    }
    else
        editable.endDate = nil;
    [table reloadData];
}

-(IBAction) didChangePickerValue:(UIDatePicker *) sender{
switch (dateSelector) {
	case 0:
		editable.startDate = sender.date;
		
		break;
	case 1:
		editable.endDate = sender.date;
	default:
		break;
}
	
	[table reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
switch (indexPath.row) {
	case 0:
		dateSelector = 0;
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
		[datePicker setDate:editable.startDate animated:YES];
        datePicker.enabled = YES;
		[table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
		
		break;
	case 1:
		[table selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
		
		dateSelector = 1;
        [datePicker setDatePickerMode:UIDatePickerModeDate];
		if (editable.endDate!=nil){
            [datePicker setDate:editable.endDate animated:YES];
            datePicker.enabled = YES;
        }
        else
        {
            datePicker.enabled = NO;
        }                  
		break;
	default:
		break;
}
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Start / End Date";
			break;
		default:
			break;
	}
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
