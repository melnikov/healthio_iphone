//
//  NameDescription.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "NameDescription.h"
#import "IndicationsObject.h"

@implementation NameDescription

@synthesize table;
@synthesize editable;

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
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	    
    static NSString *CellIdentifier = @"IndicationsNameDescriptionCell";
	
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UITextField * tf = [[UITextField alloc]initWithFrame:CGRectMake(25, 10, 280, 20)];
	//tf.delegate = self;
	[tf addTarget:self action:@selector(textFieldDidChangeEditing:) forControlEvents:UIControlEventEditingChanged];

	if (!cell) 
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	switch (indexPath.section) {
		case 0://name
			[tf setText:[NSString stringWithFormat:@"%@",editable.name]];
			if ([editable.name isEqualToString:@"Name"])
				[tf setText:[NSString stringWithFormat:@""]];
			[tf setPlaceholder:@"Name"];
			[tf setTag:0];
			break;
		case 1:
			[tf setPlaceholder:@"Description"];
			[tf setText:[NSString stringWithFormat:@"%@",editable.description]];
			if ([editable.description isEqualToString:@"Description"])
				[tf setText:[NSString stringWithFormat:@""]];
			[tf setTag:1];
			break;
		default:
			break;
	}
	
	

	[cell addSubview:tf];
	
	//IndicationsObject * cellObject = [[datasource objectAtIndex:indexPath.row]retain];
	//[cell setData:cellObject];
	
	
	
    // Configure the cell...
    
    return cell;
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
		return @"Name";
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
