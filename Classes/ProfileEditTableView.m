//
//  ProfileEditTableView.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "ProfileEditTableView.h"
#import "ProfileObject.h"

#import "PhoneEmail.h"
#import "Birth.h"
#import "Gender.h"
#import "Height.h"
#import "Weight.h"
#import "Alcohol.h"
#import "Tobacco.h"
#import "Alerts.h"
#import "HealthIOAppDelegate.h"
#import "ClearDBAppClient.h"

#import "LoginView.h"

@implementation ProfileEditTableView

@synthesize index;
@synthesize alerts;
@synthesize ages;
@synthesize heights;
@synthesize weights;
@synthesize smokers;
@synthesize drinkers;
@synthesize genders;

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 9;	
	
}
/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
 
 return @"User Profile";
 
 }*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.section) {
		case 0: //name/desc
			return 60;
		case 7:
        case 8:
			return 90;
			break;
            
		default:
			return 30;
	}
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		//if (indexPath.section<3){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		//}
		//else {
		//	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//}
		
    }
	
	[cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
	[cell.textLabel setNumberOfLines:2];
	
	[cell.detailTextLabel setLineBreakMode:UILineBreakModeWordWrap];
	[cell.detailTextLabel setNumberOfLines:3];
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    switch (indexPath.section) {
		case 0: //name/desc
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.textLabel setText:@"Location\nE-mail"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@",
                                           delegate.profile.city,
                                           delegate.profile.email
                                           ]];
            
            break;
        case 1: //start/end
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            
            [cell.textLabel setText:@"Year of Birth"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[self.ages objectAtIndex:delegate.profile.age+1]]];
            break;

            
        case 2:
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            
            [cell.textLabel setText:@"Gender"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[self.genders objectAtIndex:delegate.profile.gender+1]]];
            break;
            
        case 3:
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            
            [cell.textLabel setText:@"Height, Cm"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[self.heights objectAtIndex:delegate.profile.height+1]]];
            break;
            
        case 4:
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            
            [cell.textLabel setText:@"Weight, Kgs"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[self.weights objectAtIndex:delegate.profile.weight+1]]];
            break;
            
        case 5:
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            
            [cell.textLabel setText:@"Alcohol (Drinks/Week)"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[self.drinkers objectAtIndex:delegate.profile.drinkStatus+1]]];
            break;
            
            
        case 6:
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            
            [cell.textLabel setText:@"Tobacco (per Day)"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[self.smokers objectAtIndex:delegate.profile.tobaccoStatus+1]]];
            break;
            
            
        case 7:
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            
            [cell.textLabel setText:@"Alert Notification\n"];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"Vibrate\nShow Alert Box\nPlay sound (Marimba)"]];
            break;
            
            
        case 8:
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.textLabel setNumberOfLines:3];
            [cell.textLabel setText:[NSString stringWithFormat:@"(c) Health.IO Corporation 2011\nAll Rights Reserved\nVersion 1.05"]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.detailTextLabel setText:@""];
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
        case 0: // phone/email
            vc = [[PhoneEmail alloc]init];
            break;
        case 1:
            vc = [[Birth alloc]init];
            break;
        case 2:
            vc = [[Gender alloc]initWithNibName:@"Birth" bundle:nil];
            break;
        case 3:
            vc = [[Height alloc]initWithNibName:@"Birth" bundle:nil];

            break;
        case 4:
            vc = [[Weight alloc]initWithNibName:@"Birth" bundle:nil];

            break;
        case 5:
            vc = [[Alcohol alloc]initWithNibName:@"Birth" bundle:nil];
            break;

        case 6:
            vc = [[Tobacco alloc]initWithNibName:@"Birth" bundle:nil];
            break;
        case 7:
            return;
           // vc = [[Alerts alloc]init];
            break;
        default:
            break;
    }
      [self.navigationController pushViewController:vc animated:YES];
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


-(void) viewWillAppear:(BOOL)animated{
    [table reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(clearDBDidFinishQuery:) 
     name:@"cdbReadyEvent" 
     object:nil]; 
    
    self.title = @"User Profile";
    self.navigationItem.title = @"User Profile";
    //  [self.navigationController setNavigationBarHidden:YES];
    self.index = -1;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone 
                                                                            target:self action:@selector(didClickSaveButton:)];
    table.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
    
    [super viewDidLoad];
    
    self.ages = [[NSArray alloc]initWithObjects:
                 [NSString stringWithFormat:@"Not set"],
                 [NSString stringWithFormat:@"2010-2019"],
                 [NSString stringWithFormat:@"2000-2009"],
                 [NSString stringWithFormat:@"1990-1999"],
                 [NSString stringWithFormat:@"1980-1989"],
                 [NSString stringWithFormat:@"1970-1979"],
                 [NSString stringWithFormat:@"1960-1969"],
                 [NSString stringWithFormat:@"1950-1959"],
                 [NSString stringWithFormat:@"1940-1949"],
                 [NSString stringWithFormat:@"1930-1939"],
                 [NSString stringWithFormat:@"1920-1929"],
                 [NSString stringWithFormat:@"1910-1919"]
                 , nil];
    
    self.weights =  [[NSArray alloc]initWithObjects:
                     [NSString stringWithFormat:@"Not set"],
                     [NSString stringWithFormat:@"Below 50"],
                     [NSString stringWithFormat:@"50-74"],
                     [NSString stringWithFormat:@"75-99"],
                     [NSString stringWithFormat:@"100-124"],
                     [NSString stringWithFormat:@"125-149"],
                     [NSString stringWithFormat:@"Over 150"]
                     , nil];
    
    self.heights = [[NSArray alloc]initWithObjects:
                    [NSString stringWithFormat:@"Not set"],
                    [NSString stringWithFormat:@"Below 50"],
                    [NSString stringWithFormat:@"50-99"],
                    [NSString stringWithFormat:@"100-149"],
                    [NSString stringWithFormat:@"150-199"],
                    [NSString stringWithFormat:@"200-249"],
                    [NSString stringWithFormat:@"250-299"],
                    [NSString stringWithFormat:@"Over 300"]
                    , nil];
    
    self.genders =  [[NSArray alloc]initWithObjects:
                     [NSString stringWithFormat:@"Not set"],
                     [NSString stringWithFormat:@"Female"],
                     [NSString stringWithFormat:@"Male"]
                     , nil];
    
    self.drinkers = [[NSArray alloc]initWithObjects:
                     [NSString stringWithFormat:@"Not set"],
                     [NSString stringWithFormat:@"Non-drinker"],
                     [NSString stringWithFormat:@"1-2"],
                     [NSString stringWithFormat:@"5-10"],
                     [NSString stringWithFormat:@"10-20"],
                     [NSString stringWithFormat:@"More than 20"]
                     , nil];
    
    self.smokers =  [[NSArray alloc]initWithObjects:
                     [NSString stringWithFormat:@"Not set"],
                     [NSString stringWithFormat:@"Non-smoker"],
                     [NSString stringWithFormat:@"1-2"],
                     [NSString stringWithFormat:@"3-5"],
                     [NSString stringWithFormat:@"5-10"],
                     [NSString stringWithFormat:@"10-20"],
                     [NSString stringWithFormat:@"20 or more"]
                     , nil]; 
    
    
}

-(IBAction) didClickDoneButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

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

-(IBAction) didClickSaveButton:(id)sender{
      HealthIOAppDelegate * delegate = (HealthIOAppDelegate*)[[UIApplication sharedApplication]delegate];
    bool isValid = true;
    NSString * message;
    
    if (delegate.profile.tobaccoStatus == -1)
    {
        isValid = false;
        message = @"Please set tobacco status";
    }
    
    if (delegate.profile.drinkStatus == -1)
    {
        isValid = false;
        message = @"Please set alcohol status";
    }
    
    if (delegate.profile.weight == -1)
    {
        isValid = false;
        message = @"Please set weight";
    }
    
    if (delegate.profile.height == -1)
    {
        isValid = false;
        message = @"Please set height";
    }
    
    if (delegate.profile.gender == -1)
    {
        isValid = false;
        message = @"Please set gender";
    }
    
    if (delegate.profile.age == -1)
    {
        isValid = false;
        message = @"Please set year of birth";
    }
    
    if ([delegate.profile.city isEqualToString:@""])
    {
        isValid = false;
        message = @"Please set location";
    }
    
    
    if ([delegate.profile.email isEqualToString:@""])
    {
        isValid = false;
        message = @"Please set e-mail";
    }
    
    
    if (!isValid){
        UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    ClearDBAppClient *client = delegate.client;

    [client query:[NSString stringWithFormat:@"UPDATE users SET email='%@', city='%@', birthdate=%d, gender=%d, height=%d, weight = %d, alcohol = %d, tobacco = %d, alert = %d where id = %d",
                   delegate.profile.email,
                   delegate.profile.city,
                   delegate.profile.age,
                   delegate.profile.gender,
                   delegate.profile.height,
                   delegate.profile.weight,
                   delegate.profile.drinkStatus,
                   delegate.profile.tobaccoStatus,
                   delegate.profile.alert,
                   delegate.user_id
                   ]];  
       
}


- (void)clearDBDidFinishQuery:(NSNotification *)notification { 
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
   [self.navigationController popToRootViewControllerAnimated:NO];
    [self dismissModalViewControllerAnimated:YES];
    LoginView * lv = [[LoginView alloc]initWithForcedUid:delegate.user_id];
    [delegate.window setRootViewController:lv];
    [lv release]; 
}



- (void)dealloc {
    
    [ages release];
    [heights release];
    [smokers release];
    [drinkers release];
    [genders release];
    [super dealloc];
}


@end
