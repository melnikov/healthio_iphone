//
//  ProviderEditTable.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "ProviderEditTable.h"
#import "ProviderObject.h"
#import "HealthIOAppDelegate.h"

#import "NameSpecialty.h"
#import "CityAffiliation.h"
#import "PhoneFaxEmail.h"
#import "Rating.h"


@implementation ProviderEditTable
@synthesize index;
@synthesize editableObject;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithIndex:(int)anIndex editableObject:(NSMutableArray*)anEditableObject 
{
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
	
    self = [super init];
    if (self) {
        self.index = anIndex;
		source = anEditableObject;
		if (anIndex>-1)
		{
		//	source = anEditableObject;
			self.editableObject =  [[anEditableObject objectAtIndex:anIndex]  retain];
			self.title = @"Edit Provider";
		}
		else {
			self.title=@"Add Provider";
			editableObject = [[ProviderObject objectWithName:@"Name" specialty:0 affiliation:@"Affiliation" cityName:@"City" city:0 phone:@"" fax:@"" email:@"" rating:0] retain];
			
			
			if (source == delegate.providersPhysicians)
				editableObject.section = 0;
			else 
				if (source == delegate.providersTherapists)
					editableObject.section = 1;
				else 
					if (source == delegate.providersOthers)
						editableObject.section = 2;
			
		//	[anEditableObject addObject:editableObject];
		}
    }
    return self;
}

-(BOOL) validate{
	
	BOOL isValid = TRUE;
	
	NSString * error = @"";
	
	if ([editableObject.phone isEqualToString:@""] || [editableObject.phone isEqualToString:@"Phone"])
	{
		error = [NSString stringWithFormat:@"Phone cannot be blank"];
		isValid = FALSE;	
	}

	
	
	if ([editableObject.affiliation isEqualToString:@""] || [editableObject.affiliation isEqualToString:@"Affiliation"])
	{
		error = [NSString stringWithFormat:@"Affiliation cannot be blank"];
		isValid = FALSE;	
	}
	
	if ([editableObject.cityName isEqualToString:@""] || [editableObject.cityName isEqualToString:@"City"])
	{
		error = [NSString stringWithFormat:@"City cannot be blank"];
		isValid = FALSE;	
	}
	
	if ([editableObject.name isEqualToString:@""] || [editableObject.name isEqualToString:@"Name"])
	{
		error = [NSString stringWithFormat:@"Name cannot be blank"];
		isValid = FALSE;	
	}
	
	if (!isValid){
		
		UIAlertView * errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorView show];
		[errorView release];
	}
	
	return isValid;
	
}

#pragma mark SAVE BUTTON
-(void) didClickSaveButton:(id)sender{
	
	if (![self validate])
		return;
	
	HealthIOAppDelegate * delegate =(HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
	
	//validation goes here
	
	
	NSString * tst = [NSString stringWithFormat:@"INSERT into providers (section,name,specialty,affiliation,cityname,phone,fax,email, rating) values (%d,\"%@\",%d,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%f)",
					  editableObject.section,
					  editableObject.name,
					  editableObject.specialty,
					  editableObject.affiliation,
					  editableObject.cityName,
					  editableObject.phone,
					  editableObject.fax,
					  editableObject.email,
					  editableObject.rating
					  ];
	
	NSLog(@"%@",tst);
	
	
	if (editableObject.ID==-1) //new object
	{
		sqlite3_exec(delegate.database, 
					 [tst cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
		
		int newId = sqlite3_last_insert_rowid(delegate.database);
		
        
        [delegate.client query:[NSString stringWithFormat:@"INSERT into providers (section,name,specialty,affiliation,cityname,phone,fax,email, rating,local_id,uid) values (%d,\"%@\",%d,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%f,%d,%d)",
                                editableObject.section,
                                editableObject.name,
                                editableObject.specialty,
                                editableObject.affiliation,
                                editableObject.cityName,
                                editableObject.phone,
                                editableObject.fax,
                                editableObject.email,
                                editableObject.rating,
                                newId,
                                delegate.user_id
                                ]];
        
        
        
        editableObject.ID = newId;
        
        
		[source addObject:editableObject];
		
	}
	
	else {
		sqlite3_exec(delegate.database, 
					 [[NSString stringWithFormat:@"UPDATE providers SET section=%d, name = \"%@\",specialty = \"%d\",affiliation = \"%@\",cityname = \"%@\",phone = \"%@\",fax = \"%@\",email =\"%@\", rating = %f where id=%d",
					   editableObject.section,
					   editableObject.name,
					   editableObject.specialty,
					   editableObject.affiliation,
					   editableObject.cityName,
					   editableObject.phone,
					   editableObject.fax,
					   editableObject.email,
					   editableObject.rating,
					   editableObject.ID
					   ] 
					  
					  cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
             
        
        [delegate.client query:[NSString stringWithFormat:@"UPDATE providers SET section=%d, name = \"%@\",specialty = \"%d\",affiliation = \"%@\",cityname = \"%@\",phone = \"%@\",fax = \"%@\",email =\"%@\", rating = %f where local_id=%d and uid=%d",
                                editableObject.section,
                                editableObject.name,
                                editableObject.specialty,
                                editableObject.affiliation,
                                editableObject.cityName,
                                editableObject.phone,
                                editableObject.fax,
                                editableObject.email,
                                editableObject.rating,
                                editableObject.ID,
                                delegate.user_id
                                ]];
	}
	
	
	[self.navigationController popViewControllerAnimated:YES];
	
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
	[super viewDidLoad];
	
	table.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1.0];
	
	UIBarButtonItem * saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(didClickSaveButton:)];
	[self.navigationItem setRightBarButtonItem:saveButton];
	[saveButton release];
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark delete FUNCTION

-(IBAction) didClickDeleteCell:(id)sender{
	
	HealthIOAppDelegate * delegate =(HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
	sqlite3_exec(delegate.database, 
				 [[NSString stringWithFormat:@"DELETE FROM providers where id=%d",
				   
				   editableObject.ID
				   ] 
				  
				  cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
	[delegate.client query:[NSString stringWithFormat:@"DELETE FROM providers where local_id=%d and uid=%d",
                            
                            editableObject.ID,
                            delegate.user_id
                            ] ];
	
	[source removeObjectAtIndex:index];
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.index == -1) //new event
		return 4;
	else { //allocate one more section for delete button
		return 5;
	}
	
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.section) {
		case 0: //Name/specialty
			return 60;
		case 1: //city/affiliation
			return 60;
			
		case 2: //phone/fax/email
			return 90;
			
		case 3: //rating
			return 30;
			
		default:
			return 30;
	}
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if (indexPath.section<4){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
    }
	
	[cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
	[cell.textLabel setNumberOfLines:3];
	
	[cell.detailTextLabel setLineBreakMode:UILineBreakModeWordWrap];
	[cell.detailTextLabel setNumberOfLines:3];
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	//	editableObject.lastUpdateDate = [NSDate date];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    switch (indexPath.section) {
		case 0: //name/desc
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			if (self.index==-2) {
				[cell.textLabel setText:@"Name\nDescription"];
			}
			else {
				[cell.textLabel setText:[NSString stringWithFormat:
										 @"%@\n%@",
										 @"Name",
										 @"Specialty"]];
				[cell.detailTextLabel setText:[NSString stringWithFormat:
											   @"%@\n%@",
											   editableObject.name,
											   [delegate.providersSpecialties objectAtIndex:editableObject.specialty]
											   ]];
				
			}
			
			// [cell setText:@"Name\nDescription"];
			break;
			
		case 1: //name/desc
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			[cell.textLabel setText:@"Name\nDescription"];
			[cell.textLabel setText:[NSString stringWithFormat:
									 @"%@\n%@",
									 @"City",
									 @"Affiliation"]];
			[cell.detailTextLabel setText:[NSString stringWithFormat:
										   @"%@\n%@",
										   editableObject.cityName,
										   editableObject.affiliation]];
			
			
			// [cell setText:@"Name\nDescription"];
			break;
			
			
		case 2: //name/desc
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			[cell.textLabel setText:[NSString stringWithFormat:
									 @"Phone\nFax\nEmail"]];
			[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@\n%@",
										   //								   
										   editableObject.phone,
										   editableObject.fax,
										   editableObject.email]];
			
			break;
			
			
		case 3: //start/end
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			[cell.textLabel setText:@"Rating"];
			
			NSNumber * tmp = [NSNumber numberWithFloat:editableObject.rating];
			
			if (editableObject.rating>0)
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"%d",[tmp intValue]]];
			else
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"Not set"]];
			break;
			
			
		default:
			cell.backgroundColor = [UIColor colorWithRed:.749 green:.114 blue:.086 alpha:1.0];
			[cell.textLabel setText:@"Delete"];
			[cell.textLabel setTextAlignment:UITextAlignmentCenter];
			cell.textColor = [UIColor whiteColor];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			break;
	}
	
	
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UIViewController * vc;
	
	switch (indexPath.section) {
		case 0:
			vc = [[NameSpecialty alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			
		case 1: 
			vc = [[CityAffiliation alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			
		case 2: 
			vc = [[PhoneFaxEmail alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			break;
			
		case 3: //start/end
			vc = [[Rating alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			
			
		default:
			[self didClickDeleteCell:nil];
			break;
	}
	
}


-(void) viewWillAppear:(BOOL)animated{
	[table reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
