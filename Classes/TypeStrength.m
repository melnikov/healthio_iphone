//
//  TypeStrength.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "TypeStrength.h"


#import "NameDescription.h"
#import "TreatmentObject.h"
#import "HealthIOAppDelegate.h"

@implementation TypeStrength

@synthesize table;
@synthesize editable;

@synthesize tmpName;
@synthesize tmpDescription;

@synthesize strengthField;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithEditable:(TreatmentObject*)anEditable  
{
    self = [super init];
    if (self) {
        editable = [anEditable retain];
    }
	
	//	self.tmpName = [NSString stringWithFormat:@"%@",textField.text];
	//	self.tmpDescription = [NSString stringWithFormat:@"%@",textField.text];
	
/*	table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];*/
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
	HealthIOAppDelegate * delegate;
	
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			
			delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
			return [delegate.treatmentTypes count];
			break;

		default:
			break;
	}
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HealthIOAppDelegate * delegate;
	delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    static NSString *CellIdentifier = @"TreatmentTypeStrengthCell";
	
	
	
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//TextField * tf = [[UITextField alloc]initWithFrame:CGRectMake(25, 10, 280, 20)];
	//tf.delegate = self;
	//tf addTarget:self action:@selector(textFieldDidChangeEditing:) forControlEvents:UIControlEventEditingChanged];
	
	//if (!cell) 
	//{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
	//}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	

								
	switch (indexPath.section) {
		case 0://strength
			[cell.textLabel setText:@"Strength"];
			UITextField * tf = [[UITextField alloc]initWithFrame:CGRectMake(105, 10, 180, 20)];
			tf.text = [NSString stringWithFormat:@"%@",editable.strengthValue];
			tf.delegate = self;
			[tf setPlaceholder:@"Mg, vials, etc."];
			[tf addTarget:self action:@selector(textFieldDidChangeEditing:) forControlEvents:UIControlEventEditingChanged];
			[cell addSubview:tf];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			//[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",editable.strengthValue]];
			break;
		case 1:
			
			[cell.textLabel setText:[NSString stringWithFormat:@"%@",[delegate.treatmentTypes objectAtIndex:indexPath.row]]];
			if (editable.treatmentType == indexPath.row)
				[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			else {
				[cell setAccessoryType:UITableViewCellAccessoryNone];
			}

			break;
		default:
			break;
	}
	
	
	
	//[cell addSubview:tf];
	
	//IndicationsObject * cellObject = [[datasource objectAtIndex:indexPath.row]retain];
	//[cell setData:cellObject];
	
	
	
    // Configure the cell...
    
    return cell;
}

- (void)textFieldDidChangeEditing:(UITextField *)textField{
	switch (textField.tag) {
		case 0:
			editable.strengthValue = [NSString stringWithFormat:@"%@",textField.text];
			break;
		default:
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Treatment Strength";

			break;
		case 1:
			return @"Treatment Type";
			break;
		default:
			break;
	}
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section==1){
	[strengthField resignFirstResponder];
		editable.treatmentType = indexPath.row;
		[table reloadData];
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