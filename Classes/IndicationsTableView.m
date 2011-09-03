//
//  IndicationsTableView.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "IndicationsTableView.h"
#import "IndicationsObject.h"
#import "HealthIOAppDelegate.h"
#import "IndicationsTableCell.h"
#import "IndicationsEditTableView.h"

#import "ProfileEditTableView.h"


@implementation IndicationsTableView

@synthesize header1;
@synthesize header2;
@synthesize header3;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    NSLog(@"Loaded with UID = %d",((HealthIOAppDelegate*)[[UIApplication sharedApplication]delegate]).user_id);
    [super viewDidLoad];
	
	UIBarButtonItem * profileButton = [[UIBarButtonItem alloc]initWithTitle:@"Profile" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickProfileAction:)];
	

	[self.navigationItem setLeftBarButtonItem:profileButton];
	
	[profileButton release];
	
    profileButton = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickLogoutButton:)];
	
	
	[self.navigationItem setRightBarButtonItem:profileButton];
	[profileButton release];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(IBAction) didClickProfileAction:(id)sender{
    ProfileEditTableView * pv = [[ProfileEditTableView alloc] init];
    UINavigationController * unc = [[UINavigationController alloc] initWithRootViewController:pv];
    [self presentModalViewController:unc animated:NO];
    [unc release];
    [pv release];
}
-(IBAction) didClickLogoutButton:(id)sender{
    
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
    [delegate doLogout];
    
}


- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

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
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSMutableArray * datasource;
	
	HealthIOAppDelegate * delegate = [[UIApplication sharedApplication]delegate];
	
	switch (section) {
		case 0:
			datasource = delegate.indicationsConditions;
			break;
			
		case 1:
			datasource = delegate.indicationsSymptoms;
			break;
		case 2:
			datasource = delegate.indicationsTestResults;
			break;
	}
	return [datasource count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Conditions";
			break;
			
		case 1:
			return @"Symptoms";
			break;
			
		case 2:
			return @"Test Results";
			break;
			
		default:
			return @"";
	}
}*/


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableArray * datasource;
	
	HealthIOAppDelegate * delegate = [[UIApplication sharedApplication]delegate];
	
	switch (indexPath.section) {
		case 0:
			datasource = delegate.indicationsConditions;
			break;
		
		case 1:
			datasource = delegate.indicationsSymptoms;
			break;
		case 2:
			datasource = delegate.indicationsTestResults;
			break;
	}
    
    static NSString *CellIdentifier = @"IndicationsCell";
	
	IndicationsTableCell * cell = (IndicationsTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) 
	{
		NSArray *arr_xib=[[NSBundle mainBundle] loadNibNamed:@"IndicationsTableCell" owner:nil options:nil];
		cell = [arr_xib objectAtIndex:0];
	}
	
	IndicationsObject * cellObject = [[datasource objectAtIndex:indexPath.row]retain];
	[cell setData:cellObject];
	
	
	
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 31;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	UIView * header = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)]retain];
	
	header.backgroundColor = [UIColor colorWithRed:0.596 green:0.651 blue:0.235 alpha:0.7];
	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	addButton.frame = CGRectMake(280, 1, 29, 29);
	addButton.tag = section;
	[addButton addTarget:self action:@selector(didPressAddButton:) forControlEvents:UIControlEventTouchUpInside];
	[header addSubview:addButton];
//	[addButton release];
	UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 270, 20)];
	title.font = [UIFont boldSystemFontOfSize:16];
	
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UIColor colorWithRed:0.180 green:0.251 blue:0.078 alpha:1.0];
	switch (section) {
		case 0:
			title.text = @"Conditions";
			break;
			
		case 1:
			title.text = @"Symptoms";
			break;
			
		case 2:
			title.text = @"Test Results";
			break;
	}
	[header addSubview:title];
//	[title release];

	return header;
}

-(IBAction) didPressAddButton:(id)sender{
	int tag = ((UIButton*) sender).tag;
	NSMutableArray * datasource;
	
	HealthIOAppDelegate * delegate = [[UIApplication sharedApplication]delegate];
	
	switch (tag) {
		case 0:
			datasource = delegate.indicationsConditions;
			break;
			
		case 1:
			datasource = delegate.indicationsSymptoms;
			break;
		case 2:
			datasource = delegate.indicationsTestResults;
			break;
	}
	
	
	
    IndicationsEditTableView *detailViewController = [[IndicationsEditTableView alloc] initWithIndex:-1 
																					  editableObject:datasource];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	
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
    // Navigation logic may go here. Create and push another view controller.
    
	NSMutableArray * datasource;
	
	HealthIOAppDelegate * delegate = [[UIApplication sharedApplication]delegate];
	
	switch (indexPath.section) {
		case 0:
			datasource = delegate.indicationsConditions;
			break;
			
		case 1:
			datasource = delegate.indicationsSymptoms;
			break;
		case 2:
			datasource = delegate.indicationsTestResults;
			break;
	}
	
	
	
    IndicationsEditTableView *detailViewController = [[IndicationsEditTableView alloc] initWithIndex:indexPath.row 
																					  editableObject:datasource];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
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
	
	[header1 release];
    header1 = nil;
    [header2 release];
    header2 = nil;
    [header3 release];
    header3 = nil;
	
    [super dealloc];
}


@end

