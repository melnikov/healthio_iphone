//
//  TreatmentEditTable.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "TreatmentEditTable.h"
#import "HealthIOAppDelegate.h"
#import "TreatmentObject.h"
#import "NameDescription.h"
#import "StartEnd.h"
#import "TypeStrength.h"
#import "MedicalSystem.h"
#import "Repeat.h"


@implementation TreatmentEditTable

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
			self.editableObject =  [[anEditableObject objectAtIndex:anIndex]  retain];
			self.title = @"Edit Treatment";
		}
		else {
			self.title=@"Add Treatment";
			editableObject = [[TreatmentObject objectWithName:@"Name" description:@"Description" startDate:[NSDate date]  endDate:[NSDate date] repeatType:0 treatmentType:0 strength:@"" medicalSystem:0]retain];
			//[anEditableObject addObject:editableObject];
			
			if (source == delegate.treatmentMedication )
				editableObject.section = 0;
			else 
				if (source == delegate.treatmentTherapies)
					editableObject.section = 1;
				else 
					if (source == delegate.treatmentFood)
						editableObject.section = 2;
			
		}
    }
    return self;
}


-(BOOL) validate{
	
	BOOL isValid = TRUE;
	
	NSString * error = @"";
	
	/*
	if ([editableObject.description isEqualToString:@""] || [editableObject.description isEqualToString:@"Description"])
	{
		error = [NSString stringWithFormat:@"Description cannot be blank"];
		isValid = FALSE;	
	}*/
	
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
	
	if (editableObject.ID==-1) //new object
	{
		sqlite3_exec(delegate.database, 
					 [[NSString stringWithFormat:@"INSERT into treatments (section,name,description,startdate,enddate,lastupdate,repeat,type,strength,system,repeattime) values (%d,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%d,%d,\"%@\",%d,\"%@\")",
					   editableObject.section,
					   editableObject.name,
					   editableObject.description,
					   [editableObject.startDate description],
					   [editableObject.endDate description],
					   [editableObject.lastUpdateDate description],
					   editableObject.repeatType,
					   editableObject.treatmentType,
					   editableObject.strengthValue,
					   editableObject.medicalSystem,
					   @""/*[editableObject.repeatTime description]*/
					   ] 
					  
					  cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
		
		int newId = sqlite3_last_insert_rowid(delegate.database);
        [delegate.client startTransaction];
        [delegate.client query:[NSString stringWithFormat:@"INSERT into treatments (section,name,description,startdate,enddate,lastupdate,repeatdate,type,strength,system,repeattime,uid,local_id) values (%d,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%d,%d,\"%@\",%d,\"%@\",%d,%d)",
                                editableObject.section,
                                editableObject.name,
                                editableObject.description,
                                [editableObject.startDate description],
                                [editableObject.endDate description],
                                [editableObject.lastUpdateDate description],
                                editableObject.repeatType,
                                editableObject.treatmentType,
                                editableObject.strengthValue,
                                editableObject.medicalSystem,
                                @"",/*[editableObject.repeatTime description]*/
                                delegate.user_id,
                                newId
                                ]];
        
        [delegate.client query:[NSString stringWithFormat:@"DELETE FROM occasions where uid = %d and event_id=%d and type=%d",
                                delegate.user_id,
                                newId,
                                treatments_type
                                ]];
        
        for (NSDateComponents* component in editableObject.repeatTimes) {
            
            NSString * occ = [NSString stringWithFormat:@"INSERT INTO occasions (uid,type,year,month,weekday,day,hour,minute,event_id) values (%d,%d,%d,%d,%d,%d,%d,%d,%d)",
                              delegate.user_id,
                              treatments_type,
                              [component year],
                              [component month],
                              [component weekday],
                              [component day],
                              [component hour],
                              [component minute],
                              newId
                              
                              ];
            [delegate.client query:occ];
        }

        [delegate.client sendTransaction];
        
		editableObject.ID = newId;
		[source addObject:editableObject];
		
	}
	
	else {
		sqlite3_exec(delegate.database, 
					 [[NSString stringWithFormat:@"UPDATE treatments SET section=%d, name = \"%@\",description = \"%@\",startdate = \"%@\",enddate = \"%@\",lastupdate = \"%@\",repeat = %d,type =%d, strength = \"%@\",system = %d, repeattime = \"%@\" where id=%d",
					   editableObject.section,
					   editableObject.name,
					   editableObject.description,
					   [editableObject.startDate description],
					   [editableObject.endDate description],
					   [editableObject.lastUpdateDate description],
					   editableObject.repeatType,
					   editableObject.treatmentType,
					   editableObject.strengthValue,
					   editableObject.medicalSystem,
					   @""/*[editableObject.repeatTime description]*/,
					   editableObject.ID
					   ] 
					  
					  cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
       // [delegate.client startTransaction];
        [delegate.client startTransaction];
        [delegate.client query:[NSString stringWithFormat:@"UPDATE treatments SET section=%d, name = \"%@\",description = \"%@\",startdate = \"%@\",enddate = \"%@\",lastupdate = \"%@\",repeatdate = %d,type =%d, strength = \"%@\",system = %d, repeattime = \"%@\" where local_id=%d and uid=%d",
                                editableObject.section,
                                editableObject.name,
                                editableObject.description,
                                [editableObject.startDate description],
                                [editableObject.endDate description],
                                [editableObject.lastUpdateDate description],
                                editableObject.repeatType,
                                editableObject.treatmentType,
                                editableObject.strengthValue,
                                editableObject.medicalSystem,
                                @""/*[editableObject.repeatTime description]*/,
                                editableObject.ID,
                                delegate.user_id
                                ]];
        
        [delegate.client query:[NSString stringWithFormat:@"DELETE FROM occasions where uid = %d and event_id=%d and type=%d",
                                delegate.user_id,
                                editableObject.ID,
                                treatments_type
                                ]];
        
        for (NSDateComponents* component in editableObject.repeatTimes) {
            
            NSString * occ = [NSString stringWithFormat:@"INSERT INTO occasions (uid,type,year,month,weekday,day,hour,minute,event_id) values (%d,%d,%d,%d,%d,%d,%d,%d,%d)",
            delegate.user_id,
            treatments_type,
            [component year],
            [component month],
            [component weekday],
            [component day],
            [component hour],
            [component minute],
                        editableObject.ID
                            
            ];
            [delegate.client query:occ];
        }
        
        [delegate.client sendTransaction];
    
    
    }
	
    
    //********** save to external db
    
   // client = delegate.client;
    
	[delegate rescheduleNotifications];
    
    
	
	[self.navigationController popViewControllerAnimated:YES];
	
}


 - (void)clearDBDidFinishQuery:(NSNotification *)notification { 
     NSLog(@"Query returned");
 }


#pragma mark -
#pragma mark View lifecycle


 - (void)viewDidLoad {
 [super viewDidLoad];

	 table.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
	 
	 UIBarButtonItem * saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(didClickSaveButton:)];
	 [self.navigationItem setRightBarButtonItem:saveButton];
	 [saveButton release];
     
     [[NSNotificationCenter defaultCenter] 
      addObserver:self 
      selector:@selector(clearDBDidFinishQuery:) 
      name:@"cdbReadyEvent" 
      object:nil]; 
	 
     
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }


#pragma mark delete FUNCTION

-(IBAction) didClickDeleteCell:(id)sender{
	
	HealthIOAppDelegate * delegate =(HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
	sqlite3_exec(delegate.database, 
				 [[NSString stringWithFormat:@"DELETE FROM treatments where id=%d",
				   
				   editableObject.ID
				   ] 
				  
				  cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
	
    NSString * dlt = [NSString stringWithFormat:@"DELETE FROM treatments where local_id=%d and uid=%d",
                      
                      editableObject.ID,delegate.user_id
                      ];
    
    [delegate.client query:[NSString stringWithFormat:@"DELETE FROM occasions where uid = %d and event_id=%d and type=%d",
                            delegate.user_id,
                            editableObject.ID,
                            treatments_type
                            ]];
    
    [delegate.client query:dlt];
    
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
		return 5;
	else { //allocate one more section for delete button
		return 6;
	}
	
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.section) {
		case 0: //name/desc
			return 60;
		case 1: //type/strength
			return 60;
			
		case 2: //med system
			return 40;
			
		case 3: //start/end
			return 60;
			
			
		case 4://repeat
			return 60;
			
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
		if (indexPath.section<5){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
    }
	
	[cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
	[cell.textLabel setNumberOfLines:2];
	
	[cell.detailTextLabel setLineBreakMode:UILineBreakModeWordWrap];
	[cell.detailTextLabel setNumberOfLines:2];
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	editableObject.lastUpdateDate = [NSDate date];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    switch (indexPath.section) {
		case 0: //name/desc
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			if (self.index==-2) {
				[cell setText:@"Name\nDescription"];
			}
			else {
				[cell.textLabel setText:[NSString stringWithFormat:
										 @"%@\n%@",
										 @"Name",
										 @"Description"]];
				[cell.detailTextLabel setText:[NSString stringWithFormat:
											   @"%@\n%@",
											   editableObject.name,
											   editableObject.description]];
				
			}
			
			// [cell setText:@"Name\nDescription"];
			break;
			
		case 1: //name/desc
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			if (self.index==-2) {
				[cell setText:@"Name\nDescription"];
			}
			else {
				[cell.textLabel setText:[NSString stringWithFormat:
										 @"%@\n%@",
										 @"Treatment Type",
										 @"Treatment Strength"]];
				[cell.detailTextLabel setText:[NSString stringWithFormat:
											   @"%@\n%@",
											   [delegate.treatmentTypes objectAtIndex:editableObject.treatmentType],
											   editableObject.strengthValue]];
				
			}
			
			// [cell setText:@"Name\nDescription"];
			break;
			
		
		case 2: //name/desc
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			if (self.index==-2) {
				[cell setText:@"Name\nDescription"];
			}
			else {
				[cell.textLabel setText:[NSString stringWithFormat:
										 @"Medical System"]];
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",
											   [delegate.medicalTypes objectAtIndex:editableObject.medicalSystem]]];
				cell.detailTextLabel.numberOfLines = 2;
				
			}
			
			// [cell setText:@"Name\nDescription"];
			break;
		
			
		case 3: //start/end
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			
			if (self.index==-2) {
				
				[cell setText:@"Starts\nEnds"];	
			}
			else {
				
				[cell setText:@"Starts\nEnds"];	
				
				
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"dd MMM yyyy, hh:mm a"];
				
				
				
				NSString * d1 = [NSString stringWithFormat: @"%@", [formatter stringFromDate:editableObject.startDate] ];
                
				NSString * d2 = [NSString stringWithFormat: @"%@", [formatter stringFromDate:editableObject.endDate] ];
				if (!editableObject.endDate)
                    d2 = @"Not set";
                [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
				[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@", d1,d2]];
			}
			break;
			
		case 4:
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			[cell setText:@"Repeat"];
			[cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
            //*************
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"MMM dd, hh:mm a"];
			
			NSString * repTime = [formatter stringFromDate:editableObject.startDate];
            
            NSArray * repeatItems = [[NSArray alloc] initWithObjects:
                                     [NSString stringWithFormat:@"Once"],
                                     [NSString stringWithFormat:@"Daily"],
                                     [NSString stringWithFormat:@"Weekly"],
                                     [NSString stringWithFormat:@"Monthly"],
                                     [NSString stringWithFormat:@"Yearly"],
                                     nil];
            
            
            NSCalendar* cal = [NSCalendar currentCalendar];
            
            NSDateComponents* comp = [cal components:(NSWeekdayCalendarUnit | NSMonthCalendarUnit| NSDayCalendarUnit) fromDate:editableObject.startDate]; 
            if ([editableObject.repeatTimes count]>0)
                comp = [editableObject.repeatTimes objectAtIndex:0];
            
            NSArray * weekdays = [[NSArray alloc]initWithObjects:
                                  [NSString stringWithFormat:@"Monday"],
                                  [NSString stringWithFormat:@"Tuesday"],
                                  [NSString stringWithFormat:@"Wednesday"],
                                  [NSString stringWithFormat:@"Thursday"],
                                  [NSString stringWithFormat:@"Friday"],
                                  [NSString stringWithFormat:@"Saturday"],
                                  [NSString stringWithFormat:@"Sunday"],
                                  nil];
            
            
            NSArray * months = [[NSArray alloc]initWithObjects:
                                [NSString stringWithFormat:@"---"],
                                [NSString stringWithFormat:@"January"],
                                [NSString stringWithFormat:@"February"],
                                [NSString stringWithFormat:@"March"],
                                [NSString stringWithFormat:@"April"],
                                [NSString stringWithFormat:@"May"],
                                [NSString stringWithFormat:@"June"],
                                [NSString stringWithFormat:@"July"],
                                [NSString stringWithFormat:@"August"],
                                [NSString stringWithFormat:@"September"],
                                [NSString stringWithFormat:@"October"],
                                [NSString stringWithFormat:@"November"],
                                [NSString stringWithFormat:@"December"],
                                
                                
                                nil];
            int c = 0;
            
            switch (editableObject.repeatType) {
                case 2:
                    c=1;
                    break;
                case 4:
                    c=2;
                    break;
                case 8:
                    c=3;
                    break;
                case 16:
                    c=4;
                    break;
                case 32:
                    c=5;
                    break;
                case 64:
                    c=6;
                    break;
                default:
                    break;
            }
            
            switch (c) {
                case 0://once
                    if (editableObject.repeatType == 0 && [editableObject.repeatTimes count]>0)
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ on %@",[repeatItems objectAtIndex:c],
                                                       [formatter stringFromDate:[cal dateFromComponents:[editableObject.repeatTimes objectAtIndex:0]]]
                                                       
                                                       ]];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
                    
                    break;
                case 1://daily
                    if (editableObject.repeatType == 2 && [editableObject.repeatTimes count]>0)
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@, %d time(s) per day",[repeatItems objectAtIndex:c],[editableObject.repeatTimes count]]];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
                    break;
                case 2://weekly
                    if (editableObject.repeatType == 4 && [editableObject.repeatTimes count]>0)
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@, %d time(s) on %@",[repeatItems objectAtIndex:c],
                                                       [editableObject.repeatTimes count],
                                                       [weekdays objectAtIndex:[comp weekday]]]];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
                    break;
                case 3://montly
                    if (editableObject.repeatType == 8 && [editableObject.repeatTimes count]>0)
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@, %d time(s) every month on %d",
                                                       [repeatItems objectAtIndex:c],
                                                       [editableObject.repeatTimes count],
                                                       [comp day]+1
                                                       ]];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
                    break;
                case 4://yearly
                    
                    
                    if (editableObject.repeatType == 16 && [editableObject.repeatTimes count]>0)
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"Yearly, %d time(s) on %@, %d",
                                                       [editableObject.repeatTimes count],
                                                       [months objectAtIndex:[comp month]+1],
                                                       [comp day]+1
                                                       ]];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",[repeatItems objectAtIndex:c]]];
                    
                default:
                    break;
            }
            
            
            //*******************
            
            [cell.textLabel setText:@"Repeat: "];
            
            [weekdays release];
            [months release];
            
            
			
            [repeatItems release];
            
            
			break;
		default:
			cell.backgroundColor = [UIColor colorWithRed:.749 green:.114 blue:.086 alpha:1.0];

			[cell setText:@"Delete"];
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
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
	switch (indexPath.section) {
		case 0:
			vc = [[NameDescription alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			
		case 1: //treatment type/strength:
			vc = [[TypeStrength alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			
		case 2: //medical system:
			vc = [[MedicalSystem alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			break;
			
		case 3: //start/end
			vc = [[StartEnd alloc]initWithEditable:editableObject];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			break;
			break;
			
		case 4://repeat
            delegate.summaryView = self;
			vc = [[Repeat alloc]initWithEditable:editableObject];
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
