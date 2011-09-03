//
//  Repeat.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "Repeat.h"
#import "IndicationsObject.h"

#import "DailySchedule.h"
#import "OnceSchedule.h"
#import "MonthlySchedule.h"
#import "YearlySchedule.h"
#import "WeeklySchedule.h"


@implementation Repeat

@synthesize table;
@synthesize picker;
@synthesize editable;

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
    return self;
}


#pragma mark Table functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	//return 8;
    return 5;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
    static NSString *CellIdentifier = @"IndicationsRepeatCell";
	
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//UITextField * tf = [[UITextField alloc]initWithFrame:CGRectMake(25, 10, 280, 20)];
	//tf.delegate = self;
	//[tf addTarget:self action:@selector(textFieldDidChangeEditing:) forControlEvents:UIControlEventEditingChanged];
	
	if (!cell) 
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	int tmp = (1<<indexPath.row);
	int tmp3 = editable.repeatType;
	int tmp2 = tmp & tmp3;
	
	if (editable.repeatType == 0 && indexPath.row == 0){
		//cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    [self.table selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
else
	if (tmp2>0){
		//cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [self.table selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
	else {
		//cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
	[cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MMM dd, hh:mm a"]; 
	
	NSString * repTime = [formatter stringFromDate:editable.startDate];
	   
    NSArray * repeatItems = [[NSArray alloc] initWithObjects:
     [NSString stringWithFormat:@"Once"],
     [NSString stringWithFormat:@"Daily"],
     [NSString stringWithFormat:@"Weekly"],
     [NSString stringWithFormat:@"Monthly"],
     [NSString stringWithFormat:@"Yearly"],
     nil];


    NSCalendar* cal = [NSCalendar currentCalendar];
   
   
    NSDateComponents* comp = [cal components:(NSWeekdayCalendarUnit | NSMonthCalendarUnit| NSDayCalendarUnit) fromDate:editable.startDate];
   
    if ([editable.repeatTimes count]>0)
        comp = [editable.repeatTimes objectAtIndex:0];
    
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
      
    switch (indexPath.row) {
        case 0://once
            if (editable.repeatType == 0 && [editable.repeatTimes count]>0)
                [cell.textLabel setText:[NSString stringWithFormat:@"%@ on %@",[repeatItems objectAtIndex:indexPath.row],
                                         [formatter stringFromDate:[cal dateFromComponents:[editable.repeatTimes objectAtIndex:0]]]
                                         
                                         ]];
            else
                 [cell.textLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:indexPath.row]]];
                
            break;
        case 1://daily
            if (editable.repeatType == 2 && [editable.repeatTimes count]>0)
            [cell.textLabel setText:[NSString stringWithFormat:@"%@, %d time(s) per day",[repeatItems objectAtIndex:indexPath.row],[editable.repeatTimes count]]];
            else
                [cell.textLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:indexPath.row]]];
            break;
        case 2://weekly
            if (editable.repeatType == 4 && [editable.repeatTimes count]>0)
            [cell.textLabel setText:[NSString stringWithFormat:@"%@, %d time(s) on %@",[repeatItems objectAtIndex:indexPath.row],
                                     [editable.repeatTimes count],
                                     [weekdays objectAtIndex:[comp weekday]]]];
            else
                [cell.textLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:indexPath.row]]];
            break;
        case 3://montly
            if (editable.repeatType == 8 && [editable.repeatTimes count]>0)
            [cell.textLabel setText:[NSString stringWithFormat:@"%@, %d time(s) every month",
                                     [repeatItems objectAtIndex:indexPath.row],
                                     [editable.repeatTimes count],
                                     [comp day]+1
                                     ]];
            else
                [cell.textLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:indexPath.row]]];
            break;
        case 4://yearly
                 
    
            if (editable.repeatType == 16 && [editable.repeatTimes count]>0)
            [cell.textLabel setText:[NSString stringWithFormat:@"Yearly, %d time(s) on %@, %d",
                                     [editable.repeatTimes count],
                                     [months objectAtIndex:[comp month]+1],
                                     [comp day]+1
                                     ]];
            else
                [cell.textLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:indexPath.row]]];

        default:
            break;
    }

    [weekdays release];
    [months release];
							 
	
			
			
	[repeatItems release];
	
	//IndicationsObject * cellObject = [[datasource objectAtIndex:indexPath.row]retain];
	//[cell setData:cellObject];
	
	
	
    // Configure the cell...
    
    return cell;
}


-(IBAction) didChangePickerValue:(UIDatePicker *) sender{
	//editable.repeatTime = sender.date;
	[table reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
    int repeatType;
	
	if (indexPath.row>0)
		repeatType = /*editable.repeatType ^ ( */1 << indexPath.row/*)*/;
	else {
		repeatType = 0;
	}

//	[table reloadData];
    
    UIViewController * rc;
    
    switch (repeatType) {
        case 0:
            rc = [[OnceSchedule alloc]initWithEditable:editable repeatType:repeatType];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
            break;
        case 2:
            rc = [[DailySchedule alloc]initWithEditable:editable repeatType:repeatType preset:nil];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
            break;
            
        case 4:
            rc = [[WeeklySchedule alloc]initWithEditable:editable repeatType:repeatType preset:nil];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
            break;
            
        case 8:
            rc = [[MonthlySchedule alloc]initWithEditable:editable repeatType:repeatType preset:nil];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
            break;
            
        case 16:
            rc = [[YearlySchedule alloc]initWithEditable:editable repeatType:repeatType];
            [self.navigationController pushViewController:rc animated:YES];
            [rc release];
            break;
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return nil;
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

#pragma mark View LifeCycle

-(void) viewWillAppear:(BOOL)animated{
    [table reloadData];

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Repeat";
	[picker setDate:editable.startDate animated:YES];
	table.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
	self.view.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];

	picker.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];

	
	int r = 0;
	switch (editable.repeatType) {
		case 0:
			r=0;
			break;
		case 2:
			r=1;
			break;
		case 4:
			r=2;
			break;
		case 8:
			r=3;
			break;
		case 16:
			r=4;
			break;
		case 32:
			r=5;
			break;
		case 64:
			r=6;
			break;
		case 128:
			r=7;
			break;
		default:
			break;
	}
	
	[table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
    [super viewDidLoad];
}


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
