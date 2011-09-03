//
//  Severity.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/6/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "Severity.h"
#import "IndicationsObject.h"

@implementation Severity

@synthesize table;
@synthesize editable;

@synthesize sliderLabel;

@synthesize tmpName;
@synthesize tmpDescription;

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
	
	//	self.tmpName = [NSString stringWithFormat:@"%@",textField.text];
	//	self.tmpDescription = [NSString stringWithFormat:@"%@",textField.text];
	
	table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
    return self;
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didClickDoneButton:)];
	
	//[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone action:@selector(didClickDoneButton:)];
	//[doneButton setTitle: @"Save"];
	//[self.navigationItem setRightBarButtonItem:doneButton];
	//[doneButton release];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark Table functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell * cell;
	switch (indexPath.row) {
		case 0:
			 cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SeverityLabelCell"];
			if (!cell)
				cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SeverityLabelCell"];
			[cell.textLabel setText:@"Severity"];
			if (editable.severity>=0)
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"%d%%",editable.severity]];
			else
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"Not set"]];
			sliderLabel = cell.detailTextLabel;
			break;
			
		case 1:
			cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SeveritySliderCell"];
			if (!cell)
				cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SeveritySliderCell"];
			UISlider * sl = [[UISlider alloc] initWithFrame:CGRectMake(25, 5, 260, 20)];
			sl.enabled = YES;
			sl.maximumValue = 100;
			sl.minimumValue = -1;
			sl.value = editable.severity;
			
			[sl addTarget:self action:@selector(didChangeSliderValue:) forControlEvents:UIControlEventValueChanged];
			
			[cell addSubview:sl];
			
			[sl release];
			break;
			
		default:
			break;
			
	}
    
    return cell;
}

-(IBAction) didChangeSliderValue:(UISlider *) sender{

	editable.severity = sender.value;
	NSNumber * tmp = [NSNumber numberWithFloat:sender.value];
	if (sender.value>=0)
		
	sliderLabel.text = [NSString stringWithFormat:@"%d%%",[tmp intValue]];
	else {
		sliderLabel.text = @"Not set";
	}

	//[table reloadData];
	
}

- (void)textFieldDidChangeEditing:(UITextField *)textField{
	switch (textField.tag) {
		case 0:
			editable.name = [NSString stringWithFormat:@"%@",textField.text];
			break;
		case 1:
			editable.description = [NSString stringWithFormat:@"%@",textField.text];
			break;
		default:
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Severity";
			break;
		case 1:
			return @"Description";
			break;
		default:
			break;
	}
}

-(IBAction) didClickDoneButton:(id)sender{
	
	editable.name = [NSString stringWithFormat:@"%@",self.tmpName];
	editable.description = [NSString stringWithFormat:@"%@",self.tmpDescription];
	
	
}

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
	
    [tmpName release];
    tmpName = nil;
    [tmpDescription release];
    tmpDescription = nil;
	
    [super dealloc];
}


@end
