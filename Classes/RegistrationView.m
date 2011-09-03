//
//  RegistrationView.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/25/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "RegistrationView.h"
#import "HealthIOAppDelegate.h"
#import "ProfileEditTableView.h"
#import "ProfileObject.h"


@implementation RegistrationView

@synthesize lb_login;
@synthesize lb_password;
@synthesize lb_password2;
@synthesize request_tag;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    
    [lb_login release];
    [lb_password release];
    [lb_password2 release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"Registration";
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(clearDBDidFinishQuery:) 
     name:@"cdbReadyEvent" 
     object:nil]; 
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Register" style:UIBarButtonItemStyleDone target:self action:@selector(didPressRegisterButton:)];
	[self.navigationItem setRightBarButtonItem:saveButton];
	[saveButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) didPressRegisterButton:(id)sender{
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
    ClearDBAppClient *client = delegate.client;
    
    
    bool isValid = true;
    NSString * message;
    
    if (![lb_password.text isEqualToString:lb_password2.text])
    {
        isValid = false;
        message = @"Passwords do not match";
    }
    
    if ([lb_password.text isEqualToString:@""])
    {
        isValid = false;
        message = @"Password cannot be empty!";
    }
    
    if ([lb_login.text isEqualToString:@""])
    {
        isValid = false;
        message = @"Phone number cannot be empty!";
    }
    
    if (!isValid)
    {
        UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    request_tag = 0;
    
    NSString * request = [NSString stringWithFormat:@"select * from users where name = '%@'",
                          lb_login.text
                          ];
    
    [client query:request];        
    
    
    
  /*  [client startTransaction];
    [client query:[NSString stringWithFormat:@"INSERT INTO users (name,password,unique_id) values ('%@','%@','%@')",
                   lb_login.text,
                   lb_password.text,
                   unique_id
                   ]];        
    [client query:[NSString stringWithFormat:@"SELECT * from users where unique_id ='%@'",
                   unique_id
                   ]];        
    [client sendTransaction];*/

}

- (void)clearDBDidFinishQuery:(NSNotification *)notification { 
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
    ClearDBAppClient *client = delegate.client;
    switch (request_tag) {
        case 0:
            if ([client.rows count]>0) {
                UIAlertView * av =[[UIAlertView alloc]initWithTitle:@"Error" message:@"This name already exists. Please modify it and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [av release];
                return;
            }
            else
            {
                request_tag = 1;
                CFUUIDRef theUUID = CFUUIDCreate(NULL);
                CFStringRef string = CFUUIDCreateString(NULL, theUUID);
                CFRelease(theUUID);
                NSString * unique_id = [NSString stringWithFormat:@"%@",(NSString *)string];
                [client startTransaction];
                [client query:[NSString stringWithFormat:@"INSERT INTO users (name,password,unique_id) values ('%@','%@','%@')",
                               lb_login.text,
                               lb_password.text,
                               unique_id
                               ]];        
                [client query:[NSString stringWithFormat:@"SELECT * from users where unique_id ='%@'",
                               unique_id
                               ]];        
                [client sendTransaction];
            }
            break;
            
        case 1:
            
            if (client.rows)
            {
                if ([client.rows count]==2){
                    NSDictionary * response = (NSDictionary *)[client.rows objectAtIndex:1];
                    NSNumber * UID = (NSNumber*)[[response valueForKey:@"id"] objectAtIndex:0];
                    int uid = [UID intValue];
                    delegate.user_id = uid;
                    if (delegate.profile)
                    {
                        
                        [delegate.profile release];
                        delegate.profile = [[ProfileObject alloc] initWithMobileName:@"" email:@"" city:@"" gender:-1 age:-1 height:-1 weight:-1 drinkStatus:-1 tobaccoStatus:-1 ring:-1 vibrate:-1 alert:-1];
                        
                    }
                    NSLog(@"Registration set UID = %d",delegate.user_id);
                   
                    ProfileEditTableView * pv = [[ProfileEditTableView alloc] init];
                    UINavigationController * unc = [[UINavigationController alloc] initWithRootViewController:pv];
                    //[self presentModalViewController:unc animated:NO];
                    [delegate.window setRootViewController:unc];
                    [unc release];
                }
                else if ([client.rows count]>2)
                {
                    UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"This name is already busy, please choose differnt login" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    [av release];
                    return;
                    
                }
            }
            
            break;
            
        default:
            break;
    }
    
   
}
    






@end
