//
//  PhoneFaxEmail.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "PhoneFaxEmail.h"
#import "ProviderObject.h"
#import "HealthIOAppDelegate.h"


@implementation PhoneFaxEmail

@synthesize table;
@synthesize editable;

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
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
    static NSString *CellIdentifier = @"ProviderPhoneFaxEmailCell";
	
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
		case 0://phone
			[tf setText:[NSString stringWithFormat:@"%@",editable.phone]];
			if ([editable.phone isEqualToString:@"Phone"])
				[tf setText:[NSString stringWithFormat:@""]];
			[tf setPlaceholder:@"Phone"];
			[tf setTag:0];
			break;
		case 1:
			[tf setPlaceholder:@"Fax"];
			[tf setText:[NSString stringWithFormat:@"%@",editable.fax]];
			if ([editable.fax isEqualToString:@"Fax"])
				[tf setText:[NSString stringWithFormat:@""]];
			[tf setTag:1];
			break;
		case 2:
			[tf setPlaceholder:@"Email"];
			[tf setText:[NSString stringWithFormat:@"%@",editable.email]];
			if ([editable.email isEqualToString:@"Email"])
				[tf setText:[NSString stringWithFormat:@""]];
			[tf setTag:2];
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
			editable.phone = [NSString stringWithFormat:@"%@",textField.text];
			break;
		case 1:
			editable.fax = [NSString stringWithFormat:@"%@",textField.text];
			break;
		case 2:
			editable.email = [NSString stringWithFormat:@"%@",textField.text];
			break;
			
		default:
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Phone";
			break;
		case 1:
			return @"Fax";
			break;
		case 2:
			return @"E-Mail";
			break;
		default:
			break;
	}
}

-(IBAction) didClickDoneButton:(id)sender{
	
	
	
	
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

