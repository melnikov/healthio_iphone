//
//  CityAffiliation.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/5/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "PhoneEmail.h"
#import "HealthIOAppDelegate.h"
#import "Autocomplete.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileObject.h"

@implementation PhoneEmail

@synthesize table;

@synthesize cityField;

@synthesize tmpName;
@synthesize tmpDescription;

@synthesize suggestTable;


	

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	return 25;
	
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
	
    table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    //	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
	
	suggestTable = [[UITableView alloc]initWithFrame:CGRectMake(27, 92, 270 , 100) style:UITableViewStylePlain];
	suggestTable.delegate = self;
	suggestTable.dataSource = self;
	suggestTable.backgroundColor = [UIColor whiteColor];
	suggestTable.separatorColor = [UIColor lightGrayColor];
	suggestTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    

    
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
	
	autocomplete = [[Autocomplete alloc] initWithArray: delegate.cityList];
    [suggestTable removeFromSuperview];
	
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
	if (tableView == self.table) {
		return 2;
	}
	else {
		return 1;
	}
    
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (tableView == self.table)
		return 1;
	else {
		if (suggestions)
		{
			return [suggestions count];
		}
		
		return 0;
	}
    
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	cityField.text = [suggestions objectAtIndex:indexPath.row];
	[suggestTable removeFromSuperview];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
	
	if (tableView == self.table) {
		
		
		static NSString *CellIdentifier = @"ProviderCityAffiliationCell";
		
		UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		UITextField * tf = [[UITextField alloc]initWithFrame:CGRectMake(25, 10, 280, 20)];
		
		//tf.delegate = self;
		[tf addTarget:self action:@selector(textFieldDidChangeEditing:) forControlEvents:UIControlEventEditingChanged];
		[tf addTarget:self action:@selector(textFieldDidStartEditing:) forControlEvents:UIControlEventEditingDidBegin];
		
		if (!cell) 
		{
			cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		switch (indexPath.section) {
			case 0://name
				[tf setText:[NSString stringWithFormat:@"%@",delegate.profile.city]];
				if ([delegate.profile.city isEqualToString:@"City"])
					[tf setText:[NSString stringWithFormat:@""]];
				[tf setPlaceholder:@"Location"];
				[tf setTag:0];
				tf.autocorrectionType = UITextAutocorrectionTypeNo;
				cityField = tf;
				break;
			case 1:
				[tf setPlaceholder:@"Email"];
				[tf setText:[NSString stringWithFormat:@"%@",delegate.profile.email]];
				if ([delegate.profile.email isEqualToString:@"Email"])
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
	else {
		UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"autocompletecell"];
		if (cell2 == nil)
		{
			cell2 = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"autocompletecell"] autorelease];
		}
		
		// Configure the cell.
		cell2.textLabel.text = [suggestions objectAtIndex:indexPath.row];	
		cell2.textLabel.font = [UIFont systemFontOfSize:12];
		cell2.textLabel.textColor = [UIColor darkGrayColor];
		return cell2;
	}
	
}

- (void)textFieldDidChangeEditing:(UITextField *)textField{
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
	
    switch (textField.tag) {
		case 0:
			delegate.profile.city = [NSString stringWithFormat:@"%@",textField.text];
			
			
			[suggestions release];
			suggestions = [[NSArray alloc] initWithArray:[autocomplete GetSuggestions:((UITextField*)textField).text]];
			if ([suggestions count]>0){
				
				int i;
				if ([suggestions count]>4)
					i=4;
				else {
					i = [suggestions count];
				}
                
				suggestTable.frame = CGRectMake(25, 91, 270, 25*i);
				[self.view addSubview:suggestTable];
				[suggestTable reloadData];
			}
			else {
				[suggestTable removeFromSuperview];
			}
			
			
			
			
			
			break;
		case 1:
			delegate.profile.email = [NSString stringWithFormat:@"%@",textField.text];
			break;
		default:
			break;
	}
}

-(void) textFieldDidStartEditing:(UITextField*) textField{
    
	if (textField.tag == 1) return;
	
	
	
	
	
	
    //	[self.view addSubview:suggestTable];
    
    
	
	
	
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (tableView==self.table){
        switch (section) {
            case 0:
                return @"Location";
                break;
            case 1:
                return @"E-mail";
                break;
            default:
                break;
        }
	}
	else {
		return nil;
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
	
	[suggestTable release];
	
    [tmpName release];
    tmpName = nil;
    [tmpDescription release];
    tmpDescription = nil;
	
    [super dealloc];
}


@end

