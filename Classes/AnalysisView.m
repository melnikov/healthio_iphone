//
//  AnalysisView.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "AnalysisView.h"
#import "ProfileEditTableView.h"
#import "TrendChart.h"
#import "ComplianceChart.h"
#import "HealthIOAppDelegate.h"
#import "QuestionObject.h"
#import "Question.h"

@implementation AnalysisView

@synthesize table;
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

- (void)viewDidLoad {
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
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSMutableArray * datasource;
	
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
	
	switch (section) {
		case 0:
			return 2;
			break;
			
		case 1:
			return 0;//[delegate.questions count] ;
			break;
		case 2:
		//	datasource = delegate.providersOthers;
			break;
	}
//	return [datasource count];
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
	
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
	
	UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AnalysisCell"];
	
	[cell.textLabel setFrame:CGRectMake(5, 5, 250, 30)];
	[cell.detailTextLabel setFrame:CGRectMake(5, 25, 250, 30)];
	cell.textLabel.font = [UIFont systemFontOfSize:16.0];
	
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					[cell.textLabel setText:@"Trend Chart"];
					[cell.detailTextLabel setText:@"Indications, Treatments over time"];
					break;
				case 1:
					[cell.textLabel setText:@"Compliance Chart"];
					[cell.detailTextLabel setText:@"Adherence trends over time"];
					break;	
				default:
					break;
			}
			break;
		case 1:
					[cell.textLabel setText:[NSString stringWithFormat:@"%@", ((QuestionObject*) [delegate.questions objectAtIndex:indexPath.row]).question] ];
					if (((QuestionObject*) [delegate.questions objectAtIndex:indexPath.row]).answer>=0) {
						[cell.detailTextLabel setText:
						 [NSString stringWithFormat:@"%@", 
						  [((QuestionObject*) [delegate.questions objectAtIndex:indexPath.row]).variants objectAtIndex:
						   ((QuestionObject*) [delegate.questions objectAtIndex:indexPath.row]).answer ] ]];

					}
			
					
			
			break;

		default:
			break;
	}
	[cell.textLabel setFrame:CGRectMake(5, 5, 250, 30)];
	[cell.detailTextLabel setFrame:CGRectMake(5, 25, 250, 30)];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 50.0;
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
	//[header addSubview:addButton];
	//	[addButton release];
	UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 270, 20)];
	title.font = [UIFont boldSystemFontOfSize:16];
	
	title.backgroundColor = [UIColor clearColor];
	title.textColor = [UIColor colorWithRed:0.180 green:0.251 blue:0.078 alpha:1.0];

	switch (section) {
		case 0:
			title.text = @"Your Charts";
			break;
			
		case 1:
			title.text = @"Your Responses";
			break;
			
	
	}
	[header addSubview:title];
	//	[title release];
	
	return header;
}

-(IBAction) didPressAddButton:(id)sender{}
	/*int tag = ((UIButton*) sender).tag;
	NSMutableArray * datasource;
	
	HealthIOAppDelegate * delegate = [[UIApplication sharedApplication]delegate];
	
	switch (tag) {
		case 0:
			datasource = delegate.providersPhysicians;
			break;
			
		case 1:
			datasource = delegate.providersTherapists;
			break;
		case 2:
			datasource = delegate.providersOthers;
			break;*/
//	}
	
	/*
	 
	 TreatmentEditTable *detailViewController = [[TreatmentEditTable alloc] initWithIndex:-1 
	 editableObject:datasource];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
//}

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
	
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
	UIViewController * vc;
	switch (indexPath.section) {
		case 0:
			
			switch (indexPath.row) {
			
					
					
				case 0:
					vc = (TrendChart *)[[TrendChart alloc]init];
					break;
				case 1:
					vc = (ComplianceChart *)[[ComplianceChart alloc]init];

					break;

				default:
					break;
			}
			[self.navigationController pushViewController:vc animated:YES];
			break;
			
		case 1:
			if (((QuestionObject*) [delegate.questions objectAtIndex:indexPath.row]).answer>=0)
				return;
			Question * vc = [[Question alloc]initWithIndex:indexPath.row];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
	}
	
	
	
	/*  TreatmentEditTable *detailViewController = [[TreatmentEditTable alloc] initWithIndex:indexPath.row 
	 editableObject:datasource];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];*/
}


-(void) viewWillAppear:(BOOL)animated{
	[self.table reloadData];
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
    [super dealloc];
}


@end
