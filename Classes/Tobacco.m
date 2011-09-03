//
//  MedicalSystem.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "Tobacco.h"
#import "HealthIOAppDelegate.h"
#import "ProfileObject.h"

@implementation Tobacco

@synthesize table;
@synthesize source;


- (void)viewDidLoad {
    [super viewDidLoad];
    source =  [[NSArray alloc]initWithObjects:
               [NSString stringWithFormat:@"Not set"],
               [NSString stringWithFormat:@"Non-smoker"],
               [NSString stringWithFormat:@"1-2"],
               [NSString stringWithFormat:@"3-5"],
               [NSString stringWithFormat:@"5-10"],
               [NSString stringWithFormat:@"10-20"],
               [NSString stringWithFormat:@"20 or more"]
               , nil]; 
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
    
    return [self.source count]-1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HealthIOAppDelegate * delegate;
	delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    static NSString *CellIdentifier = @"PlainCell";
	
	
	
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//TextField * tf = [[UITextField alloc]initWithFrame:CGRectMake(25, 10, 280, 20)];
	//tf.delegate = self;
	//tf addTarget:self action:@selector(textFieldDidChangeEditing:) forControlEvents:UIControlEventEditingChanged];
	
	if (!cell) 
	{
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	
	
	switch (indexPath.section) {
		case 0:
			
			[cell.textLabel setText:[NSString stringWithFormat:@"%@",[source objectAtIndex:indexPath.row+1]]];
			if (delegate.profile.tobaccoStatus == indexPath.row)
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
            //		editable.strengthValue = [NSString stringWithFormat:@"%@",textField.text];
			break;
		default:
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Tobacco (per Day)";
			
			break;
            
		default:
			break;
	}
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    if (indexPath.section==0){
		delegate.profile.tobaccoStatus = indexPath.row;
		[table reloadData];
	}
}



-(IBAction) didClickDoneButton:(id)sender{
	
    //	editable.name = [NSString stringWithFormat:@"%@",self.tmpName];
    //	editable.description = [NSString stringWithFormat:@"%@",self.tmpDescription];
	
	
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
	
    [source release];
	
    [super dealloc];
}


@end