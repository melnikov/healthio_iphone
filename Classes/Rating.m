//
//  Rating.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "Rating.h"
#import "ProviderObject.h"

@implementation Rating

@synthesize table;
@synthesize editable;

@synthesize sliderLabel;

@synthesize tmpName;
@synthesize tmpDescription;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithEditable:(ProviderObject*)anEditable  
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
			cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"RatingLabelCell"];
			if (!cell)
				cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"RatingLabelCell"];
			[cell.textLabel setText:@"Rating"];
			NSNumber * tmp = [NSNumber numberWithFloat:editable.rating];
			if (editable.rating>0)
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"%d",[tmp intValue]]];
			else
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"Not set"]];
			sliderLabel = cell.detailTextLabel;
			break;
			
		case 1:
			cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"RatingSliderCell"];
			if (!cell)
				cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RatingSliderCell"];
			UISlider * sl = [[UISlider alloc] initWithFrame:CGRectMake(25, 5, 260, 20)];
			sl.enabled = YES;
			sl.maximumValue = 5;
			sl.minimumValue = 0;
			sl.value = editable.rating;
			
			[sl addTarget:self action:@selector(didChangeSliderValue:) forControlEvents:UIControlEventValueChanged];
			
			[cell addSubview:sl];
			
			[sl release];
			break;
			
		default:
			break;
			
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(IBAction) didChangeSliderValue:(UISlider *) sender{
	
	
	NSNumber * tmp = [NSNumber numberWithFloat:sender.value];
	
	editable.rating = sender.value;
	
	if ([tmp intValue]>0)
		
		sliderLabel.text = [NSString stringWithFormat:@"%d",[tmp intValue]];
	else {
		sliderLabel.text = @"Not set";
	}
	
	//[table reloadData];
	
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Provider's Rating";
			break;
		case 1:
			return @"Description";
			break;
		default:
			break;
	}
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
