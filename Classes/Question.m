//
//  Question.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "Question.h"
#import "QuestionObject.h"
#import "HealthIOAppDelegate.h"


@implementation Question

@synthesize index;
@synthesize table;
@synthesize lbQuestion;
@synthesize tmpAnswer;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithIndex:(int)anIndex  
{
    self = [super init];
    if (self) {
        index = anIndex;
    }
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
	HealthIOAppDelegate * delegate;
	delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    [super viewDidLoad];
	table.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];

	self.view.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1];
	self.title = @"Question";
	lbQuestion.text = [NSString stringWithFormat:@"%@",((QuestionObject*) [delegate.questions objectAtIndex:index]).question];
	tmpAnswer = -1;//((QuestionObject*) [delegate.questions objectAtIndex:index]).answer;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Answer" style:UIBarButtonItemStyleDone target:self action:@selector(didClickSaveButton:)];
	[self.navigationItem setRightBarButtonItem:saveButton];
	[saveButton release];
	//saveButton.enabled = FALSE;

}

-(IBAction) didClickSaveButton:(id)sender{
	if (tmpAnswer ==-1)
	{
		UIAlertView * av = [[UIAlertView alloc]initWithTitle:nil message:@"Please select answer" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
		[av release];
		return;
	}
	HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
	((QuestionObject*) [delegate.questions objectAtIndex:index]).answer = tmpAnswer;
	[self.navigationController popViewControllerAnimated:YES];
	
}


#pragma mark Table functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	HealthIOAppDelegate * delegate;
	delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
	return [((QuestionObject*) [delegate.questions objectAtIndex:index]).variants count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HealthIOAppDelegate * delegate;
	delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    static NSString *CellIdentifier = @"QuestionVariantCell";
	
	
	
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
			
			[cell.textLabel setText:[NSString stringWithFormat:@"%@",
									 [((QuestionObject*) [delegate.questions objectAtIndex:index]).variants objectAtIndex:indexPath.row]
									 
									 ]
			 
			 ];
			if (tmpAnswer == indexPath.row)
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



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	HealthIOAppDelegate * delegate;
	delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
	
	if (indexPath.section==0){
		tmpAnswer = indexPath.row;
		[table reloadData];
	}
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


- (void)dealloc {
    [super dealloc];
}


@end
