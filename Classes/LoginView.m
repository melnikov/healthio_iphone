//
//  LoginView.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/23/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "LoginView.h"
#import "HealthIOAppDelegate.h"
#import "TreatmentObject.h"
#import "IndicationsObject.h"
#import "ProviderObject.h"
#import "RegistrationView.h"
#import "ProfileObject.h"
#import "PasswordRetrieval.h"

@implementation LoginView

@synthesize password,login,spinner;
@synthesize request_tag;
@synthesize forcedUid;
@synthesize forced_login;
@synthesize forced_password;

@synthesize bt_pass,bt_login,bt_reset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithForced_login:(NSString*)aForced_login forced_password:(NSString*)aForced_password 
{
    self = [super init];
    if (self) {
        forced_login = [aForced_login retain];
        forced_password = [aForced_password retain];
    }
    return self;
}

- (id)initWithForcedUid:(int)aUid
{
    self = [super init];
    if (self) {
        forcedUid = aUid;
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}










#pragma mark Buttons

-(IBAction) didClickLoginButton:(id)sender{
    
    request_tag = 1;
    [client query:[NSString stringWithFormat:@"select * from users where name = '%@'and password='%@'",
                   login.text,
                   password.text]];
    
}

-(IBAction) didClickPasswordRetrievalButton:(id)sender{
    PasswordRetrieval * pv = [[PasswordRetrieval alloc]init];
    [self.navigationController pushViewController:pv animated:YES];
    [pv release];
}





- (void)clearDBDidFinishQuery:(NSNotification *)notification { 
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *) [[UIApplication sharedApplication]delegate];
    switch (request_tag) {
            
        case 1: //login
            
            if ([client.rows count]>0)
            {
                
                NSDictionary * result = [client.rows objectAtIndex:0];
                NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                NSNumber* uid = [result valueForKey:@"id"];
                
                int new_uid = [uid intValue];
                
                // if (delegate.user_id!=new_uid)
                // {
                [userDefaults setObject:uid forKey:@"user_id"];
                NSLog(@"Changed UID from %d to %d",delegate.user_id, new_uid);
                delegate.user_id = new_uid;
                //reload DB data here
                
                [login resignFirstResponder];
                [password resignFirstResponder];
                
                spinner.hidden = false;
                [spinner startAnimating];
                
                [self performSelector:@selector(reloadDataForUser:) withObject:uid];
                
                //  }
                
                
            }
            else
            {
                
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Authentication error" message:@"Login or password incorrect" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                [av release];
                
            }
            
            break;//request_tag == 1;
            
        case 2: //loading treatments
            
            [delegate.treatmentMedication removeAllObjects];
            [delegate.treatmentTherapies removeAllObjects];
            [delegate.treatmentFood removeAllObjects];
            
            
            for (NSDictionary * row in client.rows) {
                
                int Id = [(NSNumber *)[row valueForKey:@"local_id"] intValue];
                int section = [(NSNumber *)[row valueForKey:@"section"] intValue];
                NSString  * indicationName = [row valueForKey:@"name"];
                NSString  * indicationDescription = [row valueForKey:@"description"];
                
                NSDateFormatter * nf = [[NSDateFormatter alloc] init];
                [nf setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
                
                NSString  * strStartDate = [row valueForKey:@"startdate"];
                
                NSDate * startDate = [[nf dateFromString: [row valueForKey:@"startdate"]]retain];
                NSDate * endDate = [[nf dateFromString:[row valueForKey:@"enddate"]]retain];
                NSDate * lastUpdate = [[nf dateFromString:[row valueForKey:@"startdate"]]retain];
                int repeatType = [(NSNumber *)[row valueForKey:@"repeatdate"] intValue];
                int medType = [(NSNumber *)[row valueForKey:@"type"] intValue];
                NSString  * strStrength = [row valueForKey:@"strength"];
                
                int medSystem = [(NSNumber *)[row valueForKey:@"system"] intValue];
                NSDate * repeatTime = [[nf dateFromString:[row valueForKey:@"repeattime"]]retain];
                
                
                TreatmentObject * io = [[TreatmentObject objectWithName:indicationName 
                                                            description:indicationDescription 
                                                              startDate:startDate endDate:endDate repeatType:repeatType]retain];
                
                io.lastUpdateDate = lastUpdate;
                
                io.ID = Id;
                io.section = section;
                io.treatmentType = medType;
                io.medicalSystem = medSystem;
                io.strengthValue = [NSString stringWithFormat:@"%@",strStrength];
                //io.repeatTime = repeatTime;
                
                switch (section) {
                    case 0:
                        [delegate.treatmentMedication addObject:io];
                        break;
                    case 1:
                        [delegate.treatmentTherapies addObject:io];
                        break;
                        
                    case 2:
                        [delegate.treatmentFood addObject:io];
                    default:
                        break;
                }
                
            }
            
            request_tag = 3;
            [client query:[NSString stringWithFormat:@"select * from indications where uid = %d",
                           delegate.user_id]];  
            break;
            
            
        case 3://loading indications
            
            [delegate.indicationsSymptoms removeAllObjects];
            [delegate.indicationsConditions removeAllObjects];
            [delegate.indicationsTestResults removeAllObjects];
            
            
            for (NSDictionary * row in client.rows) {
                
                int Id = [(NSNumber *)[row valueForKey:@"local_id"] intValue];
                int section = [(NSNumber *)[row valueForKey:@"section"] intValue];
                NSString  * indicationName = [row valueForKey:@"name"];
                NSString  * indicationDescription = [row valueForKey:@"description"];
                
                NSDateFormatter * nf = [[NSDateFormatter alloc] init];
                [nf setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
                
                NSString  * strStartDate = [row valueForKey:@"startdate"];
                
                
                NSDate * startDate = [[nf dateFromString: strStartDate]retain];
                NSDate * endDate = [[nf dateFromString:[row valueForKey:@"enddate"]]retain];
                NSDate * lastUpdate = [[nf dateFromString:[row valueForKey:@"startdate"]]retain];
                int repeatType = [(NSNumber *)[row valueForKey:@"repeatdate"] intValue];
                // int medType = [(NSNumber *)[row valueForKey:@"type"] intValue];
                // NSString  * strStrength = [row valueForKey:@"strength"];
                
                // int medSystem = [(NSNumber *)[row valueForKey:@"system"] intValue];
                NSDate * repeatTime = [[nf dateFromString:[row valueForKey:@"repeattime"]]retain];
                
                
                IndicationsObject * io = [[IndicationsObject objectWithName:indicationName 
                                                                description:indicationDescription 
                                                                  startDate:startDate endDate:endDate repeatType:repeatType]retain];
                
                io.lastUpdateDate = lastUpdate;
                
                io.ID = Id;
                io.section = section;
                //io.treatmentType = medType;
                //io.medicalSystem = medSystem;
                //io.strengthValue = [NSString stringWithFormat:@"%@",strStrength];
                //io.repeatTime = repeatTime;
                
                switch (section) {
                    case 0:
                        [delegate.indicationsConditions addObject:io];
                        break;
                    case 1:
                        [delegate.indicationsSymptoms addObject:io];
                        break;
                        
                    case 2:
                        [delegate.indicationsTestResults addObject:io];
                    default:
                        break;
                }
                
            }
            
            request_tag = 4;
            [client query:[NSString stringWithFormat:@"select * from providers where uid = %d",
                           delegate.user_id]];  
            break; //tag=3
            
            
            
        case 4:     
            
            
            
            
            
            
            [delegate.providersPhysicians removeAllObjects];
            [delegate.providersTherapists removeAllObjects];
            [delegate.providersOthers removeAllObjects];
            
            
            for (NSDictionary * row in client.rows) {
                
                int Id = [(NSNumber *)[row valueForKey:@"local_id"] intValue];
                int section = [(NSNumber *)[row valueForKey:@"section"] intValue];
                NSString  * indicationName = [row valueForKey:@"name"];
                int specialty = [(NSNumber *)[row valueForKey:@"specialty"] intValue];
                NSString  * affiliation = [row valueForKey:@"affiliation"];
                NSString  * cityname = [row valueForKey:@"cityname"];
                NSString  * phone = [row valueForKey:@"phone"];
                NSString  * fax = [row valueForKey:@"fax"];
                NSString  * email = [row valueForKey:@"email"];
                float ration = [(NSNumber *)[row valueForKey:@"rating"] floatValue];
                
                
                
                ProviderObject * io = [[ProviderObject objectWithName:indicationName specialty:specialty affiliation:affiliation cityName:cityname city:0 phone:phone fax:fax email:email rating:ration]retain];
                
                io.ID = Id;
                io.section = section;
                
                
                switch (section) {
                    case 0:
                        [delegate.providersPhysicians addObject:io];
                        break;
                    case 1:
                        [delegate.providersTherapists addObject:io];
                        break;
                        
                    case 2:
                        [delegate.providersOthers addObject:io];
                    default:
                        break;
                }
                
            }
            
            request_tag = 5;
            [client query:[NSString stringWithFormat:@"select * FROM occasions where uid = %d",
                           delegate.user_id]];
            break;
            
            
        case 5:
            
            for (NSDictionary * row in client.rows) {
                NSCalendar * cal = [NSCalendar currentCalendar];
                NSDateComponents * component = [cal components:(NSYearCalendarUnit| NSWeekdayCalendarUnit | NSMonthCalendarUnit| NSDayCalendarUnit | NSHourCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
                NSLog(@"%@",row);
                
                int type = [((NSNumber*)[row valueForKey:@"type"]) intValue];
                int event_id = [((NSNumber*)[row valueForKey:@"event_id"]) intValue];
                int hour= [((NSNumber*)[row valueForKey:@"hour"]) intValue];
                int minute= [((NSNumber*)[row valueForKey:@"minute"]) intValue];
                int month= [((NSNumber*)[row valueForKey:@"month"]) intValue];
                int day= [((NSNumber*)[row valueForKey:@"day"]) intValue];
                int year= [((NSNumber*)[row valueForKey:@"year"]) intValue];
                int weekday= [((NSNumber*)[row valueForKey:@"weekday"]) intValue];
                
                [component setHour:hour];
                [component setMinute:minute];
                [component setMonth:month];
                [component setDay:day];
                [component setYear:year];
                [component setWeekday:weekday];
                
                switch (type) {
                    case 0:
                        for (IndicationsObject * event in delegate.indicationsConditions)
                        {
                            if (event.ID == event_id)
                            {
                                if (!event.repeatTimes)
                                    event.repeatTimes = [[NSMutableArray arrayWithCapacity:0] retain];
                                [event.repeatTimes addObject:[component retain]];
                                break;
                            }
                        }
                        
                        for (IndicationsObject * event in delegate.indicationsSymptoms)
                        {
                            if (event.ID == event_id)
                            {
                                if (!event.repeatTimes)
                                    event.repeatTimes = [[NSMutableArray arrayWithCapacity:0] retain];
                                [event.repeatTimes addObject:[component retain]];
                                break;
                            }
                        }
                        for (IndicationsObject * event in delegate.indicationsTestResults)
                        {
                            if (event.ID == event_id)
                            {
                                if (!event.repeatTimes)
                                    event.repeatTimes = [[NSMutableArray arrayWithCapacity:0] retain];
                                [event.repeatTimes addObject:[component retain]];
                                break;
                            }
                        }       
                        
                        break;
                    case 1:
                        
                        for (TreatmentObject * event in delegate.treatmentFood)
                        {
                            if (event.ID == event_id)
                            {
                                if (!event.repeatTimes)
                                    event.repeatTimes = [[NSMutableArray arrayWithCapacity:0] retain];
                                [event.repeatTimes addObject:[component retain]];
                                break;
                            }
                        }
                        
                        for (IndicationsObject * event in delegate.treatmentMedication)
                        {
                            if (event.ID == event_id)
                            {
                                if (!event.repeatTimes)
                                    event.repeatTimes = [[NSMutableArray arrayWithCapacity:0] retain];
                                [event.repeatTimes addObject:[component retain]];
                                break;
                            }
                        }
                        for (IndicationsObject * event in delegate.treatmentTherapies)
                        {
                            if (event.ID == event_id)
                            {
                                if (!event.repeatTimes)
                                    event.repeatTimes = [[NSMutableArray arrayWithCapacity:0] retain];
                                [event.repeatTimes addObject:[component retain]];
                                break;
                            }
                        }       

                        
                        break;
                    default:
                        break;
                }
                
            }
            request_tag = 6;
            [client query:[NSString stringWithFormat:@"select * FROM users where id = %d",
                           delegate.user_id]];

            
            break;
        case 6:
             for (NSDictionary * row in client.rows) {
                 
                 NSString  * city = [row valueForKey:@"city"];
                 NSString  * email = [row valueForKey:@"email"];
                 int birthdate = [(NSNumber *)[row valueForKey:@"birthdate"] intValue];
                 int gender = [(NSNumber *)[row valueForKey:@"gender"] intValue];
                 int height = [(NSNumber *)[row valueForKey:@"height"] intValue];
                 int weigth = [(NSNumber *)[row valueForKey:@"weight"] intValue];
                 int alcohol = [(NSNumber *)[row valueForKey:@"alcohol"] intValue];
                 int tobacco = [(NSNumber *)[row valueForKey:@"tobacco"] intValue];
                 int alert = [(NSNumber *)[row valueForKey:@"alert"] intValue];
                 
                 delegate.profile.city = [NSString stringWithFormat:@"%@",city];
                 delegate.profile.email = [NSString stringWithFormat:@"%@",email];
                 
                 delegate.profile.age= birthdate;
                 delegate.profile.gender = gender;
                 delegate.profile.height = height;
                 delegate.profile.weight = weigth;
                 delegate.profile.drinkStatus = alcohol;
                 delegate.profile.tobaccoStatus = tobacco;
                 delegate.profile.alert = alert;
             }
        case 7:
            
            [delegate rescheduleNotifications];
            [delegate getNextTreatment];
            [delegate.window setRootViewController:delegate.tabBarController];
            break; 
            
        default:
            break;
    }
} 

-(void) reloadDataForUser:(NSNumber*) user{
    
    request_tag = 2;
    [client query:[NSString stringWithFormat:@"select * from treatments where uid = %d",
                   [user intValue]]];   
    
}




- (void)clearDBDidFailWithError:(NSNotification *)notification { 
	NSLog(@"ClearDB Client failed to connect to the ClearDB API: %@", notification); 
} 

- (void)clearDBQueryDidFailWithError:(NSNotification *)notification { 
	NSLog(@"ClearDB query failed: %@", notification); 
} 

- (void)clearDBTransasctionDidFailWithError:(NSNotification *)notification { 
	NSLog(@"ClearDB transaction failed: %@", notification); 
} 



-(IBAction) didClickRegisterButton:(id)sender{
    RegistrationView * rv = [[RegistrationView alloc]init];
    [self.navigationController pushViewController:rv animated:YES];
    [rv release];
}










#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Back";
    
    spinner.hidden = true;
    [spinner stopAnimating];
    
    //  self.view.backgroundColor = [UIColor colorWithRed:0.596 green:0.651 blue:0.235 alpha:0.7];
    
    
    HealthIOAppDelegate * delegate = (HealthIOAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    client = delegate.client;
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(clearDBDidFinishQuery:) 
     name:@"cdbReadyEvent" 
     object:nil]; 
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(clearDBDidFailWithError:) 
     name:@"cdbConnectFailedEvent" 
     object:nil]; 
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(clearDBQueryDidFailWithError:) 
     name:@"cdbQueryFailedEvent" 
     object:nil]; 
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(clearDBTransasctionDidFailWithError:) 
     name:@"cdbTransactionFailedEvent" 
     object:nil]; 

    if (forcedUid >0)
    {
        NSNumber * new_uid = [NSNumber numberWithInt:forcedUid];
        [[NSUserDefaults standardUserDefaults]setObject:new_uid forKey:@"user_id"];
        NSLog(@"Just reloading data from %d",delegate.user_id);
       
        //reload DB data here
        [login setHidden:YES];
        [password setHidden:YES];
        [bt_pass setHidden:YES];
        [bt_login setHidden:YES];
        [bt_reset setHidden:YES];
        [login resignFirstResponder];
        [password resignFirstResponder];
        
        [login removeFromSuperview];
        [password removeFromSuperview];
        [bt_pass removeFromSuperview];
        [bt_login removeFromSuperview];
        [bt_reset removeFromSuperview];
        [login removeFromSuperview];
        [password removeFromSuperview];

        
        
        
        spinner.hidden = false;
        [spinner startAnimating];
        
        [self performSelector:@selector(reloadDataForUser:) withObject:new_uid];
    }
   
}

-(void)viewWillAppear:(BOOL)animated{
[self.navigationController setNavigationBarHidden:YES];
    [login resignFirstResponder];
    [password resignFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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

@end
