//
//  HealthIOAppDelegate.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "HealthIOAppDelegate.h"
#import "IndicationsObject.h"
#import "TreatmentObject.h"
#import "ProviderObject.h"
#import "QuestionObject.h"
#import "LoginView.h"
#import "ClearDBAppClient.h"
#import "ProfileObject.h"

@implementation HealthIOAppDelegate

@synthesize client;

@synthesize profile;

@synthesize user_id;
@synthesize window;
@synthesize tabBarController;

@synthesize summaryView;

@synthesize indicationsConditions;
@synthesize indicationsSymptoms;
@synthesize indicationsTestResults;
@synthesize cityList;

@synthesize treatmentMedication;
@synthesize treatmentTherapies;
@synthesize treatmentFood;

@synthesize treatmentTypes;
@synthesize medicalTypes;

@synthesize providersPhysicians;
@synthesize providersTherapists;
@synthesize providersOthers;

@synthesize providersSpecialties;

@synthesize database;
@synthesize statement;

@synthesize questions;



#pragma mark -
#pragma mark Application lifecycle

+(NSDate *) getNextOccurence:(IndicationsObject *) candidate{
    
	if ([[NSDate date] earlierDate:candidate.endDate] == candidate.endDate)
		return nil; //event is in the past already
	
	/*if (candidate.repeatType == 0 && ([[NSDate date] earlierDate:candidate.startDate] == candidate.startDate))
		return nil; //this was a once-object, and it's start date is in the past
	
	if (candidate.repeatType ==0) {
		
		return [candidate startDate];
		
	}*/
    
    NSCalendar * cal = [NSCalendar currentCalendar]; 
    
    if (candidate.repeatType == 0) //once
    //this means that the repeat type set to once, and the first (and only) component
    //of repeatTimes array is exactly our date. Let's check it
    
    {
        NSDateComponents * comp = [candidate.repeatTimes objectAtIndex:0];
        NSDate * onceDate = [cal dateFromComponents:comp];
    
        if ([[NSDate date] earlierDate:onceDate] == onceDate)
            return nil;
        else
            return onceDate;
    }
    
    
    NSDate * earlyDate;
    
    NSDateComponents * today = [cal components:(NSWeekdayCalendarUnit| NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    //******************* DAILY
    
    
    if (candidate.repeatType==2)
    {
        //this means that repeatType set to daily, and every component of repeatTimes contains time components only
        
        // today variable contains components for today. We'll do the following:
        
        // create an array of date with occurences today and tomorrow, check them against EndDate and will return the earliest
        
        NSMutableArray * tempDates = [[NSMutableArray alloc]initWithCapacity:0];
        
        for (NSDateComponents * comp in candidate.repeatTimes) {
            NSDateComponents * tmp = [comp copy];
            [tmp setDay:[today day]];
            [tmp setMonth:[today month]];
            [tmp setYear:[today year]];
            
            NSDate * occurenceToday = [cal dateFromComponents:tmp];
            NSDate * occurenceTomorrow = [NSDate dateWithTimeInterval:60*60*24 sinceDate:occurenceToday];
            
            if (candidate.endDate)
            {
                if ([occurenceToday earlierDate:candidate.endDate]==occurenceToday && [occurenceToday laterDate:[NSDate date]]==occurenceToday) {
                    [tempDates addObject:occurenceToday];
                }
                
                if ([occurenceTomorrow earlierDate:candidate.endDate]==occurenceTomorrow) {
                    [tempDates addObject:occurenceTomorrow];
                }
                
            }
            else //no end date set
            {
                if ([occurenceToday laterDate:[NSDate date]]==occurenceToday) {
                    [tempDates addObject:occurenceToday];
                }
                
                    [tempDates addObject:occurenceTomorrow];
            }
            
            
        }
        
        //now we have an array with all dates left for today and for tomorrow. Let's find the earliest
        
        if ([tempDates count]==0) return nil;
        
        earlyDate = [tempDates objectAtIndex:0];
        for (int j=1;j<[tempDates count];j++)
            if ([earlyDate laterDate:[tempDates objectAtIndex:j]] == earlyDate)
                earlyDate = [tempDates objectAtIndex:j];
        
        [tempDates release];
        
        return earlyDate;
        
        
    }
    
    
    if (candidate.repeatType == 4) //weekly
        
        //let's check if the day today matches; if it is - add today's date to the temp array
        //also, will check next occurence - check it against end date and add also
        //then return earliest date, or nil if array is empty
        
    {
    
        NSMutableArray * tempDates = [[NSMutableArray alloc]initWithCapacity:0];
        
        for (NSDateComponents * comp in candidate.repeatTimes) {
            
            NSDateComponents * tmp = [comp copy];
            [tmp setDay:[today day]];
            int day = [today day];
            [tmp setMonth:[today month]];
            int month = [today month];
            [tmp setYear:[today year]];
            int year = [today year];
            int h = [today weekday]-2;
            if (h<0) h = 7+h;
            int h1 = [comp weekday];
            
           // [tmp setWeekday:[today weekday]];
            NSDate * occurenceToday = [cal dateFromComponents:tmp];
            
            int dayDifference = h1 -h;
            
            if (dayDifference <=0) dayDifference = 7+dayDifference;
            
            NSDate * occurenceNextWeek = [NSDate dateWithTimeInterval:60*60*24*dayDifference sinceDate:occurenceToday];
            
            if (candidate.endDate)
            {
                if ([occurenceToday earlierDate:candidate.endDate]==occurenceToday && [occurenceToday laterDate:[NSDate date]]==occurenceToday && h1==h) {
                    [tempDates addObject:occurenceToday];
                }
                
                if ([occurenceNextWeek earlierDate:candidate.endDate]==occurenceNextWeek) {
                    [tempDates addObject:occurenceNextWeek];
                }
                
            }
            else //no end date set
            {
                if ([occurenceToday laterDate:[NSDate date]]==occurenceToday && h1==h) {
                    [tempDates addObject:occurenceToday];
                }
                
                [tempDates addObject:occurenceNextWeek];
            }
            
            
        }
        
        //now we have an array with all dates left for today and for tomorrow. Let's find the earliest
        
        if ([tempDates count]==0) return nil;
        
        earlyDate = [tempDates objectAtIndex:0];
        for (int j=1;j<[tempDates count];j++)
            if ([earlyDate laterDate:[tempDates objectAtIndex:j]] == earlyDate)
                earlyDate = [tempDates objectAtIndex:j];
        
        [tempDates release];
        
        return earlyDate;
    
    }
    
    
    
   
    if (candidate.repeatType == 8)
    //monthly    
    {
        //into array we'll add today's times (if it happens today), and the next months (if next month's dates are below end date)
        //as usual, will return the earliest
        NSMutableArray * tempDates = [[NSMutableArray alloc]initWithCapacity:0];
        
        for (NSDateComponents * comp in candidate.repeatTimes) {
            
            NSDateComponents * tmp = [comp copy];
            [tmp setDay:[today day]];
            int day = [today day];
            [tmp setMonth:[today month]];
            int month = [today month];
            [tmp setYear:[today year]];
            
            int year = [today year];
            
            
            int h = [today day];
 
            int h1 = [comp day]+1;
            
            // [tmp setWeekday:[today weekday]];
            NSDate * occurenceToday = [cal dateFromComponents:tmp];
            
            int dayDifference = h1 -h;
            
            NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[NSDate date]];
           
            int thisMonthsDays = rng.length;
            
            if (dayDifference <=0) dayDifference = thisMonthsDays - h +h1;
            
            NSDate * occurenceNextWeek = [NSDate dateWithTimeInterval:60*60*24*dayDifference sinceDate:occurenceToday];
            
            if (candidate.endDate)
            {
                if ([occurenceToday earlierDate:candidate.endDate]==occurenceToday && [occurenceToday laterDate:[NSDate date]]==occurenceToday && h1==h) {
                    [tempDates addObject:occurenceToday];
                }
                
                if ([occurenceNextWeek earlierDate:candidate.endDate]==occurenceNextWeek) {
                    [tempDates addObject:occurenceNextWeek];
                }
                
            }
            else //no end date set
            {
                if ([occurenceToday laterDate:[NSDate date]]==occurenceToday && h1==h) {
                    [tempDates addObject:occurenceToday];
                }
                
                [tempDates addObject:occurenceNextWeek];
            }
            
            
        }
        
        //now we have an array with all dates left for today and for tomorrow. Let's find the earliest
        
        if ([tempDates count]==0) return nil;
        
        earlyDate = [tempDates objectAtIndex:0];
        for (int j=1;j<[tempDates count];j++)
            if ([earlyDate laterDate:[tempDates objectAtIndex:j]] == earlyDate)
                earlyDate = [tempDates objectAtIndex:j];
        
        [tempDates release];
        
        return earlyDate;
        
        
    
    }
    
    
    
    if (candidate.repeatType == 16)
        //yearly    
    {
        //into array we'll add today's times (if it happens today), and the next year's (if next year's dates are below end date)
        //as usual, will return the earliest
        NSMutableArray * tempDates = [[NSMutableArray alloc]initWithCapacity:0];
        
        for (NSDateComponents * comp in candidate.repeatTimes) {
            
            NSDateComponents * tmp = [comp copy];
            [tmp setDay:[today day]];
            int day = [today day];
            [tmp setMonth:[today month]];
            int month = [today month];
            [tmp setYear:[today year]];
            
            int year = [today year];
            
            
            int h = [today day];
            
            int h1 = [comp day]+1;
            
            // [tmp setWeekday:[today weekday]];
            NSDate * occurenceToday = [cal dateFromComponents:tmp];
            
            int dayDifference = h1 -h;
            
            NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]];
            
            int thisYearDays;
            
            if (((year+1) % 4 == 0) && ((year+1) % 100 != 0) || ((year+1) % 400 == 0))
                thisYearDays = 366; // Leap Year
                else
                    thisYearDays = 365;
            
            
            
            if (dayDifference <=0) dayDifference = thisYearDays - h +h1;
            
            NSDate * occurenceNextWeek = [NSDate dateWithTimeInterval:60*60*24*dayDifference sinceDate:occurenceToday];
            
            if (candidate.endDate)
            {
                if ([occurenceToday earlierDate:candidate.endDate]==occurenceToday && [occurenceToday laterDate:[NSDate date]]==occurenceToday && h1==h) {
                    [tempDates addObject:occurenceToday];
                }
                
                if ([occurenceNextWeek earlierDate:candidate.endDate]==occurenceNextWeek) {
                    [tempDates addObject:occurenceNextWeek];
                }
                
            }
            else //no end date set
            {
                if ([occurenceToday laterDate:[NSDate date]]==occurenceToday && h1==h) {
                    [tempDates addObject:occurenceToday];
                }
                
                [tempDates addObject:occurenceNextWeek];
            }
            
            
        }
        
        //now we have an array with all dates left for today and for tomorrow. Let's find the earliest
        
        if ([tempDates count]==0) return nil;
        
        earlyDate = [tempDates objectAtIndex:0];
        for (int j=1;j<[tempDates count];j++)
            if ([earlyDate laterDate:[tempDates objectAtIndex:j]] == earlyDate)
                earlyDate = [tempDates objectAtIndex:j];
        
        [tempDates release];
        
        return earlyDate;
        
        
        
    }
  
	return nil; 
}


-(void) scheduleNotification:(IndicationsObject *) candidate{
    NSDate * candidateEarliestOccurence = [HealthIOAppDelegate getNextOccurence:candidate];
    if (candidateEarliestOccurence) {
        UILocalNotification * ul = [[UILocalNotification alloc] init];
        NSDate * fireDate = [[NSDate alloc]initWithTimeInterval:-15*60 sinceDate:candidateEarliestOccurence];
        
        NSDate * fireDateMinus15 = [fireDate laterDate:[NSDate date]];
        
        [ul setFireDate:fireDateMinus15];
        
        [fireDate release];
        
        [ul setTimeZone:[NSTimeZone defaultTimeZone]];
        ul.alertBody = [NSString stringWithFormat:@"Next medication: %@",candidate.name];
        
        ul.alertAction = [NSString stringWithFormat:@"View"];
              
        
        ul.soundName = UILocalNotificationDefaultSoundName;
        
        ul.applicationIconBadgeNumber++;
        
        [ul setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:candidate.ID], @"id", 
                         [NSNumber numberWithInt:candidate.section], @"section",
                         candidate.name, @"name",
                         candidateEarliestOccurence,@"timeLeft",
                         nil]];
        
        
        [[UIApplication sharedApplication] scheduleLocalNotification:ul];
        
        [ul release];
        
    }
}


-(void) rescheduleNotifications{
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
	
    IndicationsObject * candidate;
    
	for (int i=0; i<[treatmentMedication count]; i++) {
		candidate = [treatmentMedication objectAtIndex:i];
        
        [self scheduleNotification:candidate];
    }
    
    for (int i=0; i<[treatmentFood count]; i++) {
		candidate = [treatmentFood objectAtIndex:i];
        
        [self scheduleNotification:candidate];
    }
    
    for (int i=0; i<[treatmentTherapies count]; i++) {
		candidate = [treatmentTherapies objectAtIndex:i];
        
        [self scheduleNotification:candidate];
    }
    
}


- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    
    NSDictionary * userData = notif.userInfo;
    
    NSString * name = [userData valueForKey:@"name"];
    NSDate * timeLeft = [userData valueForKey:@"timeLeft"];
    
    int minutesLeft = [timeLeft timeIntervalSinceNow]/60;
    lastNotification = [notif retain];
    if (minutesLeft > 0){
        lastNotification = [notif retain];

        UIAlertView * av = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ in %D minutes", name,minutesLeft] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take medication",@"Snooze", nil];
        
        
    [av show];
    [av release];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSDate * fireDate;
    NSMutableDictionary * userData;
    switch (buttonIndex) {
        case 1: //OK
          /*  if (lastNotification)
                [[UIApplication sharedApplication]cancelLocalNotification:lastNotification];*/
            break;
        case 2:
            if (lastNotification){
                [lastNotification setFireDate:[lastNotification.fireDate dateByAddingTimeInterval:1*60]];
                
                [[UIApplication sharedApplication]scheduleLocalNotification:lastNotification];
                [lastNotification release];
            }
        default:
            break;
    }
}
     


-(IndicationsObject *) getNextTreatment{
	
	IndicationsObject * io = nil;
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * farFuture = [[NSDateComponents alloc] init];
    [farFuture setYear:2050];
	
    NSDate * earliestOccurence = [cal dateFromComponents:farFuture];
    
    [farFuture release];
    
  //  [HealthIOAppDelegate getNextOccurence:io];
    
	if ([treatmentMedication count]>0)
	{
		//io = [treatmentMedication objectAtIndex:0];
        //		NSDate * today = [NSDate date];
        //		NSTimeInterval interval = 100000;
        
		
		for (int i=0; i<[treatmentMedication count]; i++) {
			IndicationsObject * candidate = [treatmentMedication objectAtIndex:i];
			NSDate * candidateEarliestOccurence = [HealthIOAppDelegate getNextOccurence:candidate];
			if (candidateEarliestOccurence)
                if ([earliestOccurence earlierDate:candidateEarliestOccurence] == candidateEarliestOccurence) {
                    io = candidate;
                    earliestOccurence = candidateEarliestOccurence;
                }
		}
	}
    
    if ([treatmentTherapies count]>0)
	{
		//io = [treatmentMedication objectAtIndex:0];
        //		NSDate * today = [NSDate date];
        //		NSTimeInterval interval = 100000;
        
		
		for (int i=0; i<[treatmentTherapies count]; i++) {
			IndicationsObject * candidate = [treatmentTherapies objectAtIndex:i];
			NSDate * candidateEarliestOccurence = [HealthIOAppDelegate getNextOccurence:candidate];
			if (candidateEarliestOccurence)
                if ([earliestOccurence earlierDate:candidateEarliestOccurence] == candidateEarliestOccurence) {
                    io = candidate;
                    earliestOccurence = candidateEarliestOccurence;
                }
		}
	}
    
    if ([treatmentFood count]>0)
	{
		//io = [treatmentMedication objectAtIndex:0];
        //		NSDate * today = [NSDate date];
        //		NSTimeInterval interval = 100000;
        
		
		for (int i=0; i<[treatmentFood count]; i++) {
			IndicationsObject * candidate = [treatmentFood objectAtIndex:i];
			NSDate * candidateEarliestOccurence = [HealthIOAppDelegate getNextOccurence:candidate];
			if (candidateEarliestOccurence)
                if ([earliestOccurence earlierDate:candidateEarliestOccurence] == candidateEarliestOccurence) {
                    io = candidate;
                    earliestOccurence = candidateEarliestOccurence;
                }
		}
	}
    
    
    
    
    if ([indicationsConditions count]>0)
	{
		//io = [treatmentMedication objectAtIndex:0];
        //		NSDate * today = [NSDate date];
        //		NSTimeInterval interval = 100000;
        
		
		for (int i=0; i<[indicationsConditions count]; i++) {
			IndicationsObject * candidate = [indicationsConditions objectAtIndex:i];
			NSDate * candidateEarliestOccurence = [HealthIOAppDelegate getNextOccurence:candidate];
			if (candidateEarliestOccurence)
                if ([earliestOccurence earlierDate:candidateEarliestOccurence] == candidateEarliestOccurence) {
                    io = candidate;
                    earliestOccurence = candidateEarliestOccurence;
                }
		}
	}
    
    if ([indicationsSymptoms count]>0)
	{
		//io = [treatmentMedication objectAtIndex:0];
        //		NSDate * today = [NSDate date];
        //		NSTimeInterval interval = 100000;
        
		
		for (int i=0; i<[indicationsSymptoms count]; i++) {
			IndicationsObject * candidate = [indicationsSymptoms objectAtIndex:i];
			NSDate * candidateEarliestOccurence = [HealthIOAppDelegate getNextOccurence:candidate];
			if (candidateEarliestOccurence)
                if ([earliestOccurence earlierDate:candidateEarliestOccurence] == candidateEarliestOccurence) {
                    io = candidate;
                    earliestOccurence = candidateEarliestOccurence;
                }
		}
	}
    
    if ([indicationsTestResults count]>0)
	{
		//io = [treatmentMedication objectAtIndex:0];
        //		NSDate * today = [NSDate date];
        //		NSTimeInterval interval = 100000;
        
		
		for (int i=0; i<[indicationsTestResults count]; i++) {
			IndicationsObject * candidate = [indicationsTestResults objectAtIndex:i];
			NSDate * candidateEarliestOccurence = [HealthIOAppDelegate getNextOccurence:candidate];
			if (candidateEarliestOccurence)
                if ([earliestOccurence earlierDate:candidateEarliestOccurence] == candidateEarliestOccurence) {
                    io = candidate;
                    earliestOccurence = candidateEarliestOccurence;
                }
		}
	}
    

    
    
    
    
    
    NSDate * nextMedication = [HealthIOAppDelegate getNextOccurence:io];
    
	if (io &&  nextMedication)
	{
        NSDateFormatter * df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"dd MMM yyyy, hh:mm a"];
        
        
        NSTimeInterval timeTillMedication = [nextMedication timeIntervalSinceNow];
        
        int years = timeTillMedication / ( 60*60*24*365);
        
        int months = (timeTillMedication - years *  60*60*24*365) / ( 60*60*24*30);
        
        int days = (timeTillMedication - years *  60*60*24*365 - months * 60*60*24*30) / (60*60*24);
        
        int hours = (timeTillMedication - years *  60*60*24*365 - months * 60*60*24*30 -days*60*60*24) / (60*60);
        
        int minutes = (timeTillMedication - years *  60*60*24*365 - months * 60*60*24*30 -days*60*60*24 - hours * 60*60) / 60;
        
        NSString * intervalMsg=@"";
        
        if (years >0 || months > 11)
            intervalMsg = @"more than a year";
        
        if (months >0 && months < 12 && years == 0)
            intervalMsg = [intervalMsg stringByAppendingFormat:@"more than %d months, ",months];
        
        if (days >0 && months ==0 && years==0)
            intervalMsg = [intervalMsg stringByAppendingFormat:@"%d days, ",days];
        
        if (hours >0 &&  days==0 && months ==0 && years==0)
            intervalMsg = [intervalMsg stringByAppendingFormat:@"%d hours %d minutes ",hours,minutes];
        
        if (minutes >0 && hours==0 && days==0 && months ==0 && years==0)
            intervalMsg = [intervalMsg stringByAppendingFormat:@"%d minutes ",minutes];
        
        
        
        
        NSString * repDate = [df stringFromDate:nextMedication];
        [df release];
        NSString * msg = [NSString stringWithFormat:@"%@\nin %@\n(%@)",io.name, intervalMsg, repDate];
		UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"Next Medication" message: msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[av show];
		[av release];
	}
    if (io)
        return [io retain];
    else
        return nil;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
    client = [ClearDBAppClient alloc];
    [client initializeClearDB];
    
    client.APP_ID = __APP_ID;
    client.API_KEY = __APP_KEY;
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * path = [paths objectAtIndex:0];
	NSString * fullPath = [path stringByAppendingPathComponent:@"healthio8.db"];
	NSFileManager *fm = [NSFileManager defaultManager];
    
    profile = [[ProfileObject alloc]initWithMobileName:@"" email:@"" city:@"" gender:-1 age:-1 height:-1 weight:-1 drinkStatus:-1 tobaccoStatus:-1 ring:-1 vibrate:-1 alert:-1];
    
	BOOL exists = [fm fileExistsAtPath:fullPath];
	
	if (!exists){
		NSLog(@"DB doesn't exist. Trying to copy");
		NSString * pathForStartingDB = [[NSBundle mainBundle]pathForResource:@"healthio8" ofType:@"db"];
		
		BOOL success = [fm copyItemAtPath:pathForStartingDB 
								   toPath:fullPath 
									error:NULL];
		if (!success)
			NSLog(@"Error copying the db");
	}
	else {
		NSLog(@"Just copying");
	}
	
	const char * cFullPath = [fullPath cStringUsingEncoding:NSUTF8StringEncoding];
	if (sqlite3_open(cFullPath, &database)!=SQLITE_OK)
	{
		NSLog(@"Error opening DB");
	}
	
	
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	user_id = [userDefaults integerForKey:@"user_id"];    
    
    
	
	/*
	 
	 CREATE  TABLE  IF NOT EXISTS "main"."indication" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "section" INTEGER NOT NULL , "name" VARCHAR (100), "description" VARCHAR (100), "startdate" VARCHAR (100), "enddate" VARCHAR (100), "lastupdate" VARCHAR (100), "repeat" INTEGER DEFAULT 0, "severity" INTEGER DEFAULT 0)
	 
	 CREATE  TABLE  IF NOT EXISTS "main"."treatments" ("id" INTEGER, "section" INTEGER, "name" varchar (100), "description" varchar (100), "startdate" varchar (100), "enddate" varchar (100), "lastupdate" varchar (100), "repeat" INTEGER, "type" INTEGER, "strength" varchar (100), "system" INTEGER)
	 
	 CREATE  TABLE  IF NOT EXISTS "main"."providers" ("id" INTEGER, "name" VARCHAR (100), "specialty" INTEGER, "affiliation" VARCHAR (100), "cityname" VARCHAR (100), "phone" VARCHAR (100), "fax" VARCHAR (100), "email" VARCHAR (100), "rating" FLOAT)
	 
	 */
	
	
	
	
	//mock date for the first tab
	
	//load data for the first tab
	
#pragma mark Load data for 1st tab
	
	int result;
	
	indicationsSymptoms = [[NSMutableArray alloc] initWithCapacity:0];
	indicationsConditions = [[NSMutableArray alloc] initWithCapacity:0];
	indicationsTestResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    treatmentMedication = [[NSMutableArray alloc] initWithCapacity:0];
	treatmentTherapies = [[NSMutableArray alloc] initWithCapacity:0];
	treatmentFood = [[NSMutableArray alloc] initWithCapacity:0];
    
    providersPhysicians = [[NSMutableArray alloc]initWithCapacity:0];
	providersTherapists = [[NSMutableArray alloc]initWithCapacity:0];
	providersOthers = [[NSMutableArray alloc]initWithCapacity:0];
    
	
    if (user_id >0)
    {
        
        sqlite3_reset(statement);
        
        if (sqlite3_prepare_v2(database, "SELECT * from indications", -1, &statement, NULL)!=SQLITE_OK)
        {
            NSLog(@"Error preparing statement");
        }
        
        
        while (result=sqlite3_step(statement)==SQLITE_ROW) {
            
            int Id = sqlite3_column_int(statement, 0);
            int section = sqlite3_column_int(statement, 1);
            NSString  * indicationName = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 2)];
            NSString  * indicationDescription = [NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 3)];
            NSDateFormatter * nf = [[NSDateFormatter alloc] init];
            [nf setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
            
            NSString  * strStartDate = [NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 4)];
            
            NSLog(@"Start date: %@",strStartDate);
            
            NSDate * startDate = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 4)]]retain];
            NSDate * endDate = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 5)]]retain];
            NSDate * lastUpdate = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 6)]]retain];
            
            int repeatType = sqlite3_column_int(statement, 7);
            int severity = sqlite3_column_int(statement, 8);
            
            NSDate * repeatTime = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 9)]]retain];
            
            NSLog(@"%@",[NSString stringWithFormat:@"%d, %@, %@",Id,indicationName,indicationDescription]);
            
            IndicationsObject * io = [[IndicationsObject objectWithName:indicationName 
                                                            description:indicationDescription 
                                                              startDate:startDate endDate:endDate repeatType:repeatType]retain];
            
            io.lastUpdateDate = lastUpdate;
            //io.repeatTime = repeatTime;
            io.ID = Id;
            io.severity = severity;
            io.section = section;
            
            switch (section) {
                case 0:
                    [indicationsConditions addObject:io];
                    break;
                case 1:
                    [indicationsSymptoms addObject:io];
                    break;
                    
                case 2:
                    [indicationsTestResults addObject:io];
                default:
                    break;
            }
            
        }
        
#pragma mark Load data for 2nd tab	
        
        
        
        sqlite3_reset(statement);
        
        if (sqlite3_prepare_v2(database, "SELECT * from treatments", -1, &statement, NULL)!=SQLITE_OK)
        {
            NSLog(@"Error preparing statement");
        }
        
        
        while (result=sqlite3_step(statement)==SQLITE_ROW) {
            
            int Id = sqlite3_column_int(statement, 0);
            int section = sqlite3_column_int(statement, 1);
            NSString  * indicationName = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 2)];
            NSString  * indicationDescription = [NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 3)];
            NSDateFormatter * nf = [[NSDateFormatter alloc] init];
            [nf setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
            
            NSString  * strStartDate = [NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 4)];
            
            NSLog(@"Start date: %@",strStartDate);
            
            NSDate * startDate = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 4)]]retain];
            NSDate * endDate = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 5)]]retain];
            NSDate * lastUpdate = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 6)]]retain];
            int repeatType = sqlite3_column_int(statement, 7);
            int medType = sqlite3_column_int(statement, 8);
            NSString  * strStrength = [NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 9)];
            
            int medSystem = sqlite3_column_int(statement, 10);
            NSDate * repeatTime = [[nf dateFromString:[NSString stringWithFormat:@"%s",  (const char *) sqlite3_column_text(statement, 11)]]retain];
            
            NSLog(@"%@",[NSString stringWithFormat:@"%d, %@, %@",Id,indicationName,indicationDescription]);
            
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
                    [treatmentMedication addObject:io];
                    break;
                case 1:
                    [treatmentTherapies addObject:io];
                    break;
                    
                case 2:
                    [treatmentFood addObject:io];
                default:
                    break;
            }
            
        }
        
#pragma mark Load data for the 3rd tab
        //load data for the third tab
        
	    
        sqlite3_reset(statement);
        
        if (sqlite3_prepare_v2(database, "SELECT * from providers", -1, &statement, NULL)!=SQLITE_OK)
        {
            NSLog(@"Error preparing statement");
        }
        
        
        while (result=sqlite3_step(statement)==SQLITE_ROW) {
            
            int Id = sqlite3_column_int(statement, 0);
            int section = sqlite3_column_int(statement, 1);
            NSString  * providerName = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 2)];
            int specialty = sqlite3_column_int(statement, 3);
            NSString  * providerAffiliation = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 4)];
            NSString  * providerCityName = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 5)];
            NSString  * providerPhone = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 6)];
            NSString  * providerFax = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 7)];
            NSString  * providerEmail = [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(statement, 8)];
            float rating = sqlite3_column_double(statement, 9);
            
            ProviderObject * io = [[ProviderObject objectWithName:providerName specialty:specialty affiliation:providerAffiliation 
                                                         cityName:providerCityName city:-1 phone:providerPhone fax:providerFax 
                                                            email:providerEmail rating:rating]retain];
            
            
            io.ID = Id;
            io.section = section;
            
            switch (section) {
                case 0:
                    [providersTherapists addObject:io];
                    break;
                case 1:
                    [providersPhysicians addObject:io];
                    break;
                    
                case 2:
                    [providersOthers addObject:io];
                default:
                    break;
            }
            
        }
        
	} // if user_id > 0
	
	
	//mock question data
	
	questions = [[NSMutableArray alloc]initWithObjects:
				 
				 [QuestionObject objectWithVariants:
				  [NSArray arrayWithObjects:
				   [NSString stringWithFormat:@"Less than 4 hours"],
				   [NSString stringWithFormat:@"Less than 6 hours"],
				   [NSString stringWithFormat:@"More than 6 hours"],
				   nil
				   ]		  
                  
                                           question:@"How much did you sleep last night?" answer:-1 questionDate:nil responseDate:nil],
				 
				 [QuestionObject objectWithVariants:
				  [NSArray arrayWithObjects:
				   [NSString stringWithFormat:@"Nothing"],
				   [NSString stringWithFormat:@"Vegetables"],
				   [NSString stringWithFormat:@"Moderate diet and alcohol"],
				   nil
				   ]
				  
				  
										   question:@"What did you have for dinner?" answer:-1 questionDate:nil responseDate:nil],
				 
                 
				 
				 [QuestionObject objectWithVariants:
				  [NSArray arrayWithObjects:
				   [NSString stringWithFormat:@"Red"],
				   [NSString stringWithFormat:@"Green"],
				   [NSString stringWithFormat:@"Macintosh"],
				   nil
				   ]
				  
				  
										   question:@"What kind of apples do you like?" answer:1 questionDate:nil responseDate:nil],
				 nil];
    
    
	
	
	//list data
	
	
	treatmentTypes = [[NSArray alloc] initWithObjects:
					  [NSString stringWithFormat:@"%@",@"Tablet"],
					  [NSString stringWithFormat:@"%@",@"Capsule"],
					  [NSString stringWithFormat:@"%@",@"Injection"],
					  [NSString stringWithFormat:@"%@",@"Syrup"],
					  [NSString stringWithFormat:@"%@",@"Ointment"],
					  [NSString stringWithFormat:@"%@",@"Device"],
					  [NSString stringWithFormat:@"%@",@"Patch"],
					  [NSString stringWithFormat:@"%@",@"Other"],
					  nil];
	
	medicalTypes = [[NSArray alloc] initWithObjects:
					[NSString stringWithFormat:@"%@",@"Allopathy (Western medicine)"],
					[NSString stringWithFormat:@"%@",@"Ayurveda (Indian)"],
					[NSString stringWithFormat:@"%@",@"Aromatherapy"],
					[NSString stringWithFormat:@"%@",@"Acupressure"],
					[NSString stringWithFormat:@"%@",@"Bioelectromagnetic"],
					[NSString stringWithFormat:@"%@",@"Chinese (Traditional)"],
					[NSString stringWithFormat:@"%@",@"Chelation Therapy"],
					[NSString stringWithFormat:@"%@",@"Chiropracty"],
					[NSString stringWithFormat:@"%@",@"Diet & Nutrition"],
					[NSString stringWithFormat:@"%@",@"Homeopathy"],
					[NSString stringWithFormat:@"%@",@"Hypnotherapy"],
					[NSString stringWithFormat:@"%@",@"Hydrotherapy"],
					[NSString stringWithFormat:@"%@",@"Massage Therapy"],
					[NSString stringWithFormat:@"%@",@"Osteopathy"],
					[NSString stringWithFormat:@"%@",@"Reiki"],
					[NSString stringWithFormat:@"%@",@"Tai-Chi (Qi†Gong)"],
					[NSString stringWithFormat:@"%@",@"Unani"],
					[NSString stringWithFormat:@"%@",@"Other"],
					nil];
	
	providersSpecialties = [[NSArray alloc] initWithObjects:
							[NSString stringWithFormat:@"%@",@"Cardiovascular"],
							[NSString stringWithFormat:@"%@",@"General Practice"],
							[NSString stringWithFormat:@"%@",@"Psychiatry"],
							[NSString stringWithFormat:@"%@",@"Cardiology"],
							[NSString stringWithFormat:@"%@",@"Neurology"],
							[NSString stringWithFormat:@"%@",@"Gynaecology"],
							[NSString stringWithFormat:@"%@",@"Gerontology"],
							[NSString stringWithFormat:@"%@",@"Pulmonology"],
							[NSString stringWithFormat:@"%@",@"Pathology"],
							[NSString stringWithFormat:@"%@",@"Orthopedics"],
							[NSString stringWithFormat:@"%@",@"Pediatrics"],
							[NSString stringWithFormat:@"%@",@"Dermatology"],
							[NSString stringWithFormat:@"%@",@"Endocrinology"],
							[NSString stringWithFormat:@"%@",@"Gastroenterology"],
							[NSString stringWithFormat:@"%@",@"Oncology"],
							[NSString stringWithFormat:@"%@",@"Urology"],
							[NSString stringWithFormat:@"%@",@"ENT Specialist"],
							[NSString stringWithFormat:@"%@",@"Otolaryngology"],
							[NSString stringWithFormat:@"%@",@"Ophthalmology"],
							[NSString stringWithFormat:@"%@",@"Toxicology"],
							[NSString stringWithFormat:@"%@",@"Allergology"],
							[NSString stringWithFormat:@"%@",@"Hematology"],
							[NSString stringWithFormat:@"%@",@"Hepatology"],
							[NSString stringWithFormat:@"%@",@"Palliative medicine"],
							[NSString stringWithFormat:@"%@",@"Podiatry"],
							[NSString stringWithFormat:@"%@",@"Rheumatology"],
							[NSString stringWithFormat:@"%@",@"Radiology"],
							[NSString stringWithFormat:@"%@",@"Oral and maxillofacial surgery"],
							[NSString stringWithFormat:@"%@",@"Transplantation medicine"],
							[NSString stringWithFormat:@"%@",@"Nuclear medicine"],
							[NSString stringWithFormat:@"%@",@"Sleep medicine "],
							[NSString stringWithFormat:@"%@",@"Serology "],
							[NSString stringWithFormat:@"%@",@"Sexual health"], 
							[NSString stringWithFormat:@"%@",@"Surgery (Other)"],
							[NSString stringWithFormat:@"%@",@"Immunology"],
							[NSString stringWithFormat:@"%@",@"Infectious diseases"],
							[NSString stringWithFormat:@"%@",@"Intensive care medicine"], 
							[NSString stringWithFormat:@"%@",@"General Practice"],
							[NSString stringWithFormat:@"%@",@"Psychiatry"],
							[NSString stringWithFormat:@"%@",@"Bariatrics Surgery"],
							[NSString stringWithFormat:@"%@",@"Cardiac surgery"],
							[NSString stringWithFormat:@"%@",@"Eye surgery"],
							[NSString stringWithFormat:@"%@",@"General surgery"],
							[NSString stringWithFormat:@"%@",@"Neurosurgery"],
							[NSString stringWithFormat:@"%@",@"Ophthalmology Surgery"],
							[NSString stringWithFormat:@"%@",@"Plastic surgery"],
							[NSString stringWithFormat:@"%@",@"Surgical oncology"],
							[NSString stringWithFormat:@"%@",@" Thoracic surgery"],
							[NSString stringWithFormat:@"%@",@"Vascular surgery"],
							[NSString stringWithFormat:@"%@",@"Urology"],
							[NSString stringWithFormat:@"%@",@"Traumatology"],
							[NSString stringWithFormat:@"%@",@"Proctology"],
							[NSString stringWithFormat:@"%@",@"PCP"],
							[NSString stringWithFormat:@"%@",@"Obstetrics"],
							[NSString stringWithFormat:@"%@",@"General Medicine"],
							[NSString stringWithFormat:@"%@",@"Family Medicine"],
							[NSString stringWithFormat:@"%@",@"Opthalmology"],
							[NSString stringWithFormat:@"%@",@"Osteopathy"],
							[NSString stringWithFormat:@"%@",@"Internal Medicine"],
							nil];
	// Set the tab bar controller as the window's root view controller and display.
	
	cityList = [[NSArray alloc]initWithObjects:
				[NSString stringWithFormat:@"%@",@"Badakhshan,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Badghis,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Baghlan,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Balkh,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Bamian,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Farah,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Faryab,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Ghazni,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Ghowr,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Helmand,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Herat,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Jowzjan,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Kabul,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Kandahar,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Kapisa,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Khowst,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Konar,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Kondoz,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Laghman,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Lowgar,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Nangarhar,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Nimruz,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Nurestan,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Oruzgan,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Paktia,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Paktika,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Parvan,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Samangan,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Sar-e Pol,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Takhar,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Unknown,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Vardak,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Zabol,Afghanistan "],
				[NSString stringWithFormat:@"%@",@"Beratit,Albania "],
				[NSString stringWithFormat:@"%@",@"Dibres,Albania "],
				[NSString stringWithFormat:@"%@",@"Durresit,Albania "],
				[NSString stringWithFormat:@"%@",@"Elbasanit,Albania "],
				[NSString stringWithFormat:@"%@",@"Fierit,Albania "],
				[NSString stringWithFormat:@"%@",@"Gjirokastres,Albania "],
				[NSString stringWithFormat:@"%@",@"Korces,Albania "],
				[NSString stringWithFormat:@"%@",@"Kukesit,Albania "],
				[NSString stringWithFormat:@"%@",@"Lezhes,Albania "],
				[NSString stringWithFormat:@"%@",@"Shkodres,Albania "],
				[NSString stringWithFormat:@"%@",@"Tiranes,Albania "],
				[NSString stringWithFormat:@"%@",@"Vlores,Albania "],
				[NSString stringWithFormat:@"%@",@"Adrar,Algeria "],
				[NSString stringWithFormat:@"%@",@"Ain Defla,Algeria "],
				[NSString stringWithFormat:@"%@",@"Ain Temouchent,Algeria "],
				[NSString stringWithFormat:@"%@",@"Alger,Algeria "],
				[NSString stringWithFormat:@"%@",@"Annaba,Algeria "],
				[NSString stringWithFormat:@"%@",@"Batna,Algeria "],
				[NSString stringWithFormat:@"%@",@"Bechar,Algeria "],
				[NSString stringWithFormat:@"%@",@"Bejaia,Algeria "],
				[NSString stringWithFormat:@"%@",@"Biskra,Algeria "],
				[NSString stringWithFormat:@"%@",@"Blida,Algeria "],
				[NSString stringWithFormat:@"%@",@"Bordj Bou Arreridj,Algeria "],
				[NSString stringWithFormat:@"%@",@"Bouira,Algeria "],
				[NSString stringWithFormat:@"%@",@"Chlef,Algeria "],
				[NSString stringWithFormat:@"%@",@"Constantine,Algeria "],
				[NSString stringWithFormat:@"%@",@"Djelfa,Algeria "],
				[NSString stringWithFormat:@"%@",@"El Bayadh,Algeria "],
				[NSString stringWithFormat:@"%@",@"El Oued,Algeria "],
				[NSString stringWithFormat:@"%@",@"Ghardaia,Algeria "],
				[NSString stringWithFormat:@"%@",@"Guelma,Algeria "],
				[NSString stringWithFormat:@"%@",@"Illizi,Algeria "],
				[NSString stringWithFormat:@"%@",@"Jijel,Algeria "],
				[NSString stringWithFormat:@"%@",@"Khenchela,Algeria "],
				[NSString stringWithFormat:@"%@",@"Laghouat,Algeria "],
				[NSString stringWithFormat:@"%@",@"M'Sila,Algeria "],
				[NSString stringWithFormat:@"%@",@"Mascara,Algeria "],
				[NSString stringWithFormat:@"%@",@"Medea,Algeria "],
				[NSString stringWithFormat:@"%@",@"Mila,Algeria "],
				[NSString stringWithFormat:@"%@",@"Mostaganem,Algeria "],
				[NSString stringWithFormat:@"%@",@"Naama,Algeria "],
				[NSString stringWithFormat:@"%@",@"Oran,Algeria "],
				[NSString stringWithFormat:@"%@",@"Ouargla,Algeria "],
				[NSString stringWithFormat:@"%@",@"Oum el Bouaghi,Algeria "],
				[NSString stringWithFormat:@"%@",@"Relizane,Algeria "],
				[NSString stringWithFormat:@"%@",@"Saida,Algeria "],
				[NSString stringWithFormat:@"%@",@"Setif,Algeria "],
				[NSString stringWithFormat:@"%@",@"Sidi Bel Abbes,Algeria "],
				[NSString stringWithFormat:@"%@",@"Skikda,Algeria "],
				[NSString stringWithFormat:@"%@",@"Souk Ahras,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tamanghasset,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tebessa,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tiaret,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tindouf,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tipaza,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tissemsilt,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tizi Ouzou,Algeria "],
				[NSString stringWithFormat:@"%@",@"Tlemcen,Algeria "],
				[NSString stringWithFormat:@"%@",@"Andorra,Andorra "],
				[NSString stringWithFormat:@"%@",@"Benguela,Angola "],
				[NSString stringWithFormat:@"%@",@"Huambo,Angola "],
				[NSString stringWithFormat:@"%@",@"Luanda,Angola "],
				[NSString stringWithFormat:@"%@",@"Lunda Sul,Angola "],
				[NSString stringWithFormat:@"%@",@"Anguilla,Anguilla "],
				[NSString stringWithFormat:@"%@",@"Antarctica,Antarctica "],
				[NSString stringWithFormat:@"%@",@"Antigua & Barbuda,Antigua and Barbuda "],
				[NSString stringWithFormat:@"%@",@"Buenos Aires,Argentina "],
				[NSString stringWithFormat:@"%@",@"Catamarca,Argentina "],
				[NSString stringWithFormat:@"%@",@"Chaco,Argentina "],
				[NSString stringWithFormat:@"%@",@"Chubut,Argentina "],
				[NSString stringWithFormat:@"%@",@"Cordoba,Argentina "],
				[NSString stringWithFormat:@"%@",@"Corrientes,Argentina "],
				[NSString stringWithFormat:@"%@",@"Distrito Federal,Argentina "],
				[NSString stringWithFormat:@"%@",@"Entre Rios,Argentina "],
				[NSString stringWithFormat:@"%@",@"Formosa,Argentina "],
				[NSString stringWithFormat:@"%@",@"Jujuy,Argentina "],
				[NSString stringWithFormat:@"%@",@"La Pampa,Argentina "],
				[NSString stringWithFormat:@"%@",@"La Rioja,Argentina "],
				[NSString stringWithFormat:@"%@",@"Mendoza,Argentina "],
				[NSString stringWithFormat:@"%@",@"Misiones,Argentina "],
				[NSString stringWithFormat:@"%@",@"Neuquen,Argentina "],
				[NSString stringWithFormat:@"%@",@"Rio Negro,Argentina "],
				[NSString stringWithFormat:@"%@",@"Salta,Argentina "],
				[NSString stringWithFormat:@"%@",@"San Juan,Argentina "],
				[NSString stringWithFormat:@"%@",@"San Luis,Argentina "],
				[NSString stringWithFormat:@"%@",@"Santa Cruz,Argentina "],
				[NSString stringWithFormat:@"%@",@"Santa Fe,Argentina "],
				[NSString stringWithFormat:@"%@",@"Santiago del Estero,Argentina "],
				[NSString stringWithFormat:@"%@",@"Tierra del Fuego,Argentina "],
				[NSString stringWithFormat:@"%@",@"Tucuman,Argentina "],
				[NSString stringWithFormat:@"%@",@"Aragatsotni,Armenia "],
				[NSString stringWithFormat:@"%@",@"Ararati,Armenia "],
				[NSString stringWithFormat:@"%@",@"Armaviri,Armenia "],
				[NSString stringWithFormat:@"%@",@"Geghark'unik'i,Armenia "],
				[NSString stringWithFormat:@"%@",@"K'aghak' Yerevan,Armenia "],
				[NSString stringWithFormat:@"%@",@"Kalininskiy Rayon,Armenia "],
				[NSString stringWithFormat:@"%@",@"Kotayk'i,Armenia "],
				[NSString stringWithFormat:@"%@",@"Lorru,Armenia "],
				[NSString stringWithFormat:@"%@",@"Shiraki,Armenia "],
				[NSString stringWithFormat:@"%@",@"Syunik'i,Armenia "],
				[NSString stringWithFormat:@"%@",@"Tavushi,Armenia "],
				[NSString stringWithFormat:@"%@",@"Vayots' Dzori,Armenia "],
				[NSString stringWithFormat:@"%@",@"Aruba,Aruba "],
				[NSString stringWithFormat:@"%@",@"Australian Capital Territory,Australia "],
				[NSString stringWithFormat:@"%@",@"New South Wales,Australia "],
				[NSString stringWithFormat:@"%@",@"Northern Territory,Australia "],
				[NSString stringWithFormat:@"%@",@"Queensland,Australia "],
				[NSString stringWithFormat:@"%@",@"South Australia,Australia "],
				[NSString stringWithFormat:@"%@",@"Tasmania,Australia "],
				[NSString stringWithFormat:@"%@",@"Victoria,Australia "],
				[NSString stringWithFormat:@"%@",@"Western Australia,Australia "],
				[NSString stringWithFormat:@"%@",@"Burgenland,Austria "],
				[NSString stringWithFormat:@"%@",@"Karnten,Austria "],
				[NSString stringWithFormat:@"%@",@"Niederosterreich,Austria "],
				[NSString stringWithFormat:@"%@",@"Oberosterreich,Austria "],
				[NSString stringWithFormat:@"%@",@"Salzburg,Austria "],
				[NSString stringWithFormat:@"%@",@"Steiermark,Austria "],
				[NSString stringWithFormat:@"%@",@"Tirol,Austria "],
				[NSString stringWithFormat:@"%@",@"Vorarlberg,Austria "],
				[NSString stringWithFormat:@"%@",@"Wien,Austria "],
				[NSString stringWithFormat:@"%@",@"Abseron,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Agcabadi,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Agdam,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Agdas,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Agstafa,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Agsu,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Ali Bayramli Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Astara,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Baki Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Balakan,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Barda,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Beylaqan,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Bilasuvar,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Cabrayil,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Calilabad,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Daskasan,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Davaci,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Fuzuli,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Gadabay,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Ganca Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Goranboy,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Goycay,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Haciqabul,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Imisli,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Ismayilli,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Kalbacar,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Kurdamir,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Lacin,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Lankaran,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Lankaran Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Lerik,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Masalli,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Mingacevir Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Naftalan Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Naxcivan Muxtar Respublikasi,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Neftcala,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Oguz,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Qabala,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Qax,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Qazax,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Qobustan,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Quba,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Qubadli,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Qusar,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Saatli,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Sabirabad,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Saki,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Saki Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Salyan,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Samaxi,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Samkir,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Samux,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Siyazan,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Susa,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Tartar,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Tovuz,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Ucar,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Xacmaz,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Xankandi Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Xanlar,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Xizi,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Xocali,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Xocavand,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Yardimli,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Yevlax,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Yevlax Sahari,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Zangilan,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Zaqatala,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Zardab,Azerbaijan "],
				[NSString stringWithFormat:@"%@",@"Abaco,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Andros,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Bimini Islands,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Cat Island,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Eleuthera,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Exuma & Cays,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Grand Bahama,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Harbour Island & Spanish Wells,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Inagua,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Long Island,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Mayaguana,Bahamas "],
				[NSString stringWithFormat:@"%@",@"New Providence,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Ragged Islands,Bahamas "],
				[NSString stringWithFormat:@"%@",@"Al Hadd,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Al Manamah,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Al Mintaqah al Gharbiyah,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Al Mintaqah al Wusta,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Al Mintaqah ash Shamaliyah,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Al Muharraq,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Ar Rifa` wa al Mintaqah al Janubiyah,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Jidd Hafs,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Madinat Hamad,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Madinat `Isa,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Mintaqat Juzur Hawar,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Sitrah,Bahrain "],
				[NSString stringWithFormat:@"%@",@"Chittagong,Bangladesh "],
				[NSString stringWithFormat:@"%@",@"Dhaka,Bangladesh "],
				[NSString stringWithFormat:@"%@",@"Khulna,Bangladesh "],
				[NSString stringWithFormat:@"%@",@"Rajshahi,Bangladesh "],
				[NSString stringWithFormat:@"%@",@"Christ Church,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint Andrew,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint George,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint James,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint John,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint Joseph,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint Lucy,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint Michael,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint Peter,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint Philip,Barbados "],
				[NSString stringWithFormat:@"%@",@"Saint Thomas,Barbados "],
				[NSString stringWithFormat:@"%@",@"Brestskaya,Belarus "],
				[NSString stringWithFormat:@"%@",@"Homyel'skaya,Belarus "],
				[NSString stringWithFormat:@"%@",@"Hrodzyenskaya,Belarus "],
				[NSString stringWithFormat:@"%@",@"Mahilyowskaya,Belarus "],
				[NSString stringWithFormat:@"%@",@"Minskaya,Belarus "],
				[NSString stringWithFormat:@"%@",@"Unknown,Belarus "],
				[NSString stringWithFormat:@"%@",@"Vitsyebskaya,Belarus "],
				[NSString stringWithFormat:@"%@",@"Antwerpen,Belgium "],
				[NSString stringWithFormat:@"%@",@"Hainaut,Belgium "],
				[NSString stringWithFormat:@"%@",@"Liege,Belgium "],
				[NSString stringWithFormat:@"%@",@"Limburg,Belgium "],
				[NSString stringWithFormat:@"%@",@"Luxembourg,Belgium "],
				[NSString stringWithFormat:@"%@",@"Namur,Belgium "],
				[NSString stringWithFormat:@"%@",@"Oost-Vlaanderen,Belgium "],
				[NSString stringWithFormat:@"%@",@"Unknown,Belgium "],
				[NSString stringWithFormat:@"%@",@"West-Vlaanderen,Belgium "],
				[NSString stringWithFormat:@"%@",@"Belize,Belize "],
				[NSString stringWithFormat:@"%@",@"Cayo,Belize "],
				[NSString stringWithFormat:@"%@",@"Corozal,Belize "],
				[NSString stringWithFormat:@"%@",@"Orange Walk,Belize "],
				[NSString stringWithFormat:@"%@",@"Stann Creek,Belize "],
				[NSString stringWithFormat:@"%@",@"Toledo,Belize "],
				[NSString stringWithFormat:@"%@",@"Unknown,Benin "],
				[NSString stringWithFormat:@"%@",@"Devonshire,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Hamilton,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Paget,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Pembroke,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Saint Georges,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Sandys,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Smiths,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Southampton,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Warwick,Bermuda "],
				[NSString stringWithFormat:@"%@",@"Bhutan,Bhutan "],
				[NSString stringWithFormat:@"%@",@"Beni,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Chuquisaca,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Cochabamba,Bolivia "],
				[NSString stringWithFormat:@"%@",@"La Paz,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Oruro,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Pando,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Potosi,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Santa Cruz,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Tarija,Bolivia "],
				[NSString stringWithFormat:@"%@",@"Bosnia and Herzegovina,Bosnia and Herzegovina "],
				[NSString stringWithFormat:@"%@",@"Republika Srpska,Bosnia and Herzegovina "],
				[NSString stringWithFormat:@"%@",@"Unknown,Bosnia and Herzegovina "],
				[NSString stringWithFormat:@"%@",@"Gaborone,Botswana "],
				[NSString stringWithFormat:@"%@",@"Unknown,Botswana "],
				[NSString stringWithFormat:@"%@",@"Acre,Brazil "],
				[NSString stringWithFormat:@"%@",@"Alagoas,Brazil "],
				[NSString stringWithFormat:@"%@",@"Amapa,Brazil "],
				[NSString stringWithFormat:@"%@",@"Amazonas,Brazil "],
				[NSString stringWithFormat:@"%@",@"Bahia,Brazil "],
				[NSString stringWithFormat:@"%@",@"Ceara,Brazil "],
				[NSString stringWithFormat:@"%@",@"Distrito Federal,Brazil "],
				[NSString stringWithFormat:@"%@",@"Espirito Santo,Brazil "],
				[NSString stringWithFormat:@"%@",@"Goias,Brazil "],
				[NSString stringWithFormat:@"%@",@"Maranhao,Brazil "],
				[NSString stringWithFormat:@"%@",@"Mato Grosso,Brazil "],
				[NSString stringWithFormat:@"%@",@"Mato Grosso do Sul,Brazil "],
				[NSString stringWithFormat:@"%@",@"Minas Gerais,Brazil "],
				[NSString stringWithFormat:@"%@",@"Para,Brazil "],
				[NSString stringWithFormat:@"%@",@"Paraiba,Brazil "],
				[NSString stringWithFormat:@"%@",@"Parana,Brazil "],
				[NSString stringWithFormat:@"%@",@"Pernambuco,Brazil "],
				[NSString stringWithFormat:@"%@",@"Piaui,Brazil "],
				[NSString stringWithFormat:@"%@",@"Rio de Janeiro,Brazil "],
				[NSString stringWithFormat:@"%@",@"Rio Grande do Norte,Brazil "],
				[NSString stringWithFormat:@"%@",@"Rio Grande do Sul,Brazil "],
				[NSString stringWithFormat:@"%@",@"Rondonia,Brazil "],
				[NSString stringWithFormat:@"%@",@"Roraima,Brazil "],
				[NSString stringWithFormat:@"%@",@"Santa Catarina,Brazil "],
				[NSString stringWithFormat:@"%@",@"Sao Paulo,Brazil "],
				[NSString stringWithFormat:@"%@",@"Sergipe,Brazil "],
				[NSString stringWithFormat:@"%@",@"Tocantins,Brazil "],
				[NSString stringWithFormat:@"%@",@"British Virgin Islands,British Virgin Islands "],
				[NSString stringWithFormat:@"%@",@"Brunei,Brunei "],
				[NSString stringWithFormat:@"%@",@"Blagoevgrad,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Burgas,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Dobrich,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Gabrovo,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Khaskovo,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Kurdzhali,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Kyustendil,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Lovech,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Montana,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Pazardzhik,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Pernik,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Pleven,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Plovdiv,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Razgrad,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Ruse,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Shumen,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Silistra,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Sliven,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Smolyan,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Sofiya,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Sofiya-Grad,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Stara Zagora,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Turgovishte,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Varna,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Veliko Turnovo,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Vidin,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Vratsa,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Yambol,Bulgaria "],
				[NSString stringWithFormat:@"%@",@"Burkina Faso,Burkina Faso "],
				[NSString stringWithFormat:@"%@",@"Burundi,Burundi "],
				[NSString stringWithFormat:@"%@",@"Batdambang,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kampong Cham,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kampong Chhnang,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kampong Spoe,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kampong Thum,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kampot,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kandal,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kaoh Kong,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Kracheh,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Mondol Kiri,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Pouthisat,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Preah Vihear,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Prey Veng,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Rotanah Kiri,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Siem Reab,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Stoeng Treng,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Svay Rieng,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Takev,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Unknown,Cambodia "],
				[NSString stringWithFormat:@"%@",@"Cameroon,Cameroon "],
				[NSString stringWithFormat:@"%@",@"Alberta,Canada "],
				[NSString stringWithFormat:@"%@",@"British Columbia,Canada "],
				[NSString stringWithFormat:@"%@",@"Manitoba,Canada "],
				[NSString stringWithFormat:@"%@",@"New Brunswick,Canada "],
				[NSString stringWithFormat:@"%@",@"Newfoundland and Labrador,Canada "],
				[NSString stringWithFormat:@"%@",@"Northwest Territories,Canada "],
				[NSString stringWithFormat:@"%@",@"Nova Scotia,Canada "],
				[NSString stringWithFormat:@"%@",@"Nunavut,Canada "],
				[NSString stringWithFormat:@"%@",@"Ontario,Canada "],
				[NSString stringWithFormat:@"%@",@"Prince Edward Island,Canada "],
				[NSString stringWithFormat:@"%@",@"Quebec,Canada "],
				[NSString stringWithFormat:@"%@",@"Saskatchewan,Canada "],
				[NSString stringWithFormat:@"%@",@"Yukon,Canada "],
				[NSString stringWithFormat:@"%@",@"Cape Verde,Cape Verde "],
				[NSString stringWithFormat:@"%@",@"Cayman Islands,Cayman Islands "],
				[NSString stringWithFormat:@"%@",@"Central African Republic,Central African Republic "],
				[NSString stringWithFormat:@"%@",@"Batha,Chad "],
				[NSString stringWithFormat:@"%@",@"Biltine,Chad "],
				[NSString stringWithFormat:@"%@",@"Borkou-Ennedi-Tibesti,Chad "],
				[NSString stringWithFormat:@"%@",@"Chari-Baguirmi,Chad "],
				[NSString stringWithFormat:@"%@",@"Guera,Chad "],
				[NSString stringWithFormat:@"%@",@"Kanem,Chad "],
				[NSString stringWithFormat:@"%@",@"Lac,Chad "],
				[NSString stringWithFormat:@"%@",@"Logone Occidental,Chad "],
				[NSString stringWithFormat:@"%@",@"Logone Oriental,Chad "],
				[NSString stringWithFormat:@"%@",@"Mayo-Kebbi,Chad "],
				[NSString stringWithFormat:@"%@",@"Moyen-Chari,Chad "],
				[NSString stringWithFormat:@"%@",@"Ouaddai,Chad "],
				[NSString stringWithFormat:@"%@",@"Salamat,Chad "],
				[NSString stringWithFormat:@"%@",@"Tandjile,Chad "],
				[NSString stringWithFormat:@"%@",@"Aisen del General Carlos Ibanez del Campo,Chile "],
				[NSString stringWithFormat:@"%@",@"Antofagasta,Chile "],
				[NSString stringWithFormat:@"%@",@"Araucania,Chile "],
				[NSString stringWithFormat:@"%@",@"Atacama,Chile "],
				[NSString stringWithFormat:@"%@",@"Bio-Bio,Chile "],
				[NSString stringWithFormat:@"%@",@"Coquimbo,Chile "],
				[NSString stringWithFormat:@"%@",@"Libertador G.B. O'Higgins,Chile "],
				[NSString stringWithFormat:@"%@",@"Los Lagos,Chile "],
				[NSString stringWithFormat:@"%@",@"Magallanes y de la Antartica Chilena,Chile "],
				[NSString stringWithFormat:@"%@",@"Maule,Chile "],
				[NSString stringWithFormat:@"%@",@"Region Metropolitana,Chile "],
				[NSString stringWithFormat:@"%@",@"Tarapaca,Chile "],
				[NSString stringWithFormat:@"%@",@"Valparaiso,Chile "],
				[NSString stringWithFormat:@"%@",@"Anhui,China "],
				[NSString stringWithFormat:@"%@",@"Beijing Shi,China "],
				[NSString stringWithFormat:@"%@",@"Chongqing Shi,China "],
				[NSString stringWithFormat:@"%@",@"Fujian,China "],
				[NSString stringWithFormat:@"%@",@"Gansu,China "],
				[NSString stringWithFormat:@"%@",@"Guangdong,China "],
				[NSString stringWithFormat:@"%@",@"Guangxi Zhuangzu,China "],
				[NSString stringWithFormat:@"%@",@"Guizhou,China "],
				[NSString stringWithFormat:@"%@",@"Hainan,China "],
				[NSString stringWithFormat:@"%@",@"Hebei,China "],
				[NSString stringWithFormat:@"%@",@"Heilongjiang,China "],
				[NSString stringWithFormat:@"%@",@"Henan,China "],
				[NSString stringWithFormat:@"%@",@"Hubei,China "],
				[NSString stringWithFormat:@"%@",@"Hunan,China "],
				[NSString stringWithFormat:@"%@",@"Inner Mongolia,China "],
				[NSString stringWithFormat:@"%@",@"Jiangsu,China "],
				[NSString stringWithFormat:@"%@",@"Jiangxi,China "],
				[NSString stringWithFormat:@"%@",@"Jilin,China "],
				[NSString stringWithFormat:@"%@",@"Liaoning,China "],
				[NSString stringWithFormat:@"%@",@"Ningxia Huizu,China "],
				[NSString stringWithFormat:@"%@",@"Qinghai,China "],
				[NSString stringWithFormat:@"%@",@"Shaanxi,China "],
				[NSString stringWithFormat:@"%@",@"Shandong,China "],
				[NSString stringWithFormat:@"%@",@"Shanxi,China "],
				[NSString stringWithFormat:@"%@",@"Sichuan,China "],
				[NSString stringWithFormat:@"%@",@"Tibet,China "],
				[NSString stringWithFormat:@"%@",@"Unknown,China "],
				[NSString stringWithFormat:@"%@",@"Xinjiang Uygur,China "],
				[NSString stringWithFormat:@"%@",@"Yunnan,China "],
				[NSString stringWithFormat:@"%@",@"Zhejiang,China "],
				[NSString stringWithFormat:@"%@",@"Christmas Island,Christmas Island "],
				[NSString stringWithFormat:@"%@",@"Antioquia,Columbia "],
				[NSString stringWithFormat:@"%@",@"Atlantico,Columbia "],
				[NSString stringWithFormat:@"%@",@"Bogota,Columbia "],
				[NSString stringWithFormat:@"%@",@"Bolivar,Columbia "],
				[NSString stringWithFormat:@"%@",@"Cauca,Columbia "],
				[NSString stringWithFormat:@"%@",@"Cundinamarca,Columbia "],
				[NSString stringWithFormat:@"%@",@"Magdalena,Columbia "],
				[NSString stringWithFormat:@"%@",@"Meta,Columbia "],
				[NSString stringWithFormat:@"%@",@"Santander,Columbia "],
				[NSString stringWithFormat:@"%@",@"Valle del Cauca,Columbia "],
				[NSString stringWithFormat:@"%@",@"Comoros,Comoros "],
				[NSString stringWithFormat:@"%@",@"Bouenza,Congo "],
				[NSString stringWithFormat:@"%@",@"Brazzaville,Congo "],
				[NSString stringWithFormat:@"%@",@"Cuvette,Congo "],
				[NSString stringWithFormat:@"%@",@"Kouilou,Congo "],
				[NSString stringWithFormat:@"%@",@"Lekoumou,Congo "],
				[NSString stringWithFormat:@"%@",@"Likouala,Congo "],
				[NSString stringWithFormat:@"%@",@"Niari,Congo "],
				[NSString stringWithFormat:@"%@",@"Plateaux,Congo "],
				[NSString stringWithFormat:@"%@",@"Pool,Congo "],
				[NSString stringWithFormat:@"%@",@"Sangha,Congo "],
				[NSString stringWithFormat:@"%@",@"Cook Islands,Cook Islands "],
				[NSString stringWithFormat:@"%@",@"Alajuela,Costa Rica "],
				[NSString stringWithFormat:@"%@",@"Cartago,Costa Rica "],
				[NSString stringWithFormat:@"%@",@"Guanacaste,Costa Rica "],
				[NSString stringWithFormat:@"%@",@"Heredia,Costa Rica "],
				[NSString stringWithFormat:@"%@",@"Limon,Costa Rica "],
				[NSString stringWithFormat:@"%@",@"Puntarenas,Costa Rica "],
				[NSString stringWithFormat:@"%@",@"San Jose,Costa Rica "],
				[NSString stringWithFormat:@"%@",@"Cote D'Ivoire,Cote D'Ivoire "],
				[NSString stringWithFormat:@"%@",@"Bjelovarsko-Bilogorska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Brodsko-Posavska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Dubrovacko-Neretvanska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Grad Zagreb,Croatia "],
				[NSString stringWithFormat:@"%@",@"Istarska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Karlovacka,Croatia "],
				[NSString stringWithFormat:@"%@",@"Koprivnicko-Krizevacka,Croatia "],
				[NSString stringWithFormat:@"%@",@"Krapinsko-Zagorska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Licko-Senjska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Medimurska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Osjecko-Baranjska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Pozesko-Slavonska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Primorsko-Goranska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Sibensko-Kninska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Sisacko-Moslavacka,Croatia "],
				[NSString stringWithFormat:@"%@",@"Splitsko-Dalmatinska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Varazdinska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Viroviticko-Podravska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Vukovarsko-Srijemska,Croatia "],
				[NSString stringWithFormat:@"%@",@"Zagrebacka,Croatia "],
				[NSString stringWithFormat:@"%@",@"Camaguey,Cuba "],
				[NSString stringWithFormat:@"%@",@"Ciego de Avila,Cuba "],
				[NSString stringWithFormat:@"%@",@"Cienfuegos,Cuba "],
				[NSString stringWithFormat:@"%@",@"Ciudad de la Habana,Cuba "],
				[NSString stringWithFormat:@"%@",@"Granma,Cuba "],
				[NSString stringWithFormat:@"%@",@"Guantanamo,Cuba "],
				[NSString stringWithFormat:@"%@",@"Holguin,Cuba "],
				[NSString stringWithFormat:@"%@",@"Isla de la Juventud,Cuba "],
				[NSString stringWithFormat:@"%@",@"La Habana,Cuba "],
				[NSString stringWithFormat:@"%@",@"Las Tunas,Cuba "],
				[NSString stringWithFormat:@"%@",@"Matanzas,Cuba "],
				[NSString stringWithFormat:@"%@",@"Pinar del Rio,Cuba "],
				[NSString stringWithFormat:@"%@",@"Sancti Spiritus,Cuba "],
				[NSString stringWithFormat:@"%@",@"Santiago de Cuba,Cuba "],
				[NSString stringWithFormat:@"%@",@"Villa Clara,Cuba "],
				[NSString stringWithFormat:@"%@",@"Cyprus,Cyprus "],
				[NSString stringWithFormat:@"%@",@"Czech Republic,Czech Republic "],
				[NSString stringWithFormat:@"%@",@"Bandundu,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Bas-Congo,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Equateur,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Kasai-Occidental,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Katanga,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Kinshasa,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Kivu,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Maniema,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Nord-Kivu,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Orientale,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Sud-Kivu,Democratic Repubilic of Congo "],
				[NSString stringWithFormat:@"%@",@"Arhus Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Bornholms Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Frederiksberg Kommune,Denmark "],
				[NSString stringWithFormat:@"%@",@"Frederiksborg Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Fyns Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Kobenhavns Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Kobenhavns Kommune,Denmark "],
				[NSString stringWithFormat:@"%@",@"Nordjyllands Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Ribe Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Ringkobing Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Roskilde Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Sonderjyllands Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Storstroms Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Vejle Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Vestsjaellands Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Viborg Amt,Denmark "],
				[NSString stringWithFormat:@"%@",@"Djibouti,Djibouti "],
				[NSString stringWithFormat:@"%@",@"Dominica,Dominica "],
				[NSString stringWithFormat:@"%@",@"Azua,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Baoruco,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Barahona,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Dajabon,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Distrito Nacional,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Duarte,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"El Seibo,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Elias Pina,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Espaillat,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Hato Mayor,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Independencia,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"La Altagracia,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"La Romana,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"La Vega,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Maria Trinidad Sanchez,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Monsenor Nouel,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Monte Cristi,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Monte Plata,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Pedernales,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Peravia,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Puerto Plata,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Salcedo,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Samana,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"San Cristobal,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"San Juan,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"San Pedro de Macoris,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Sanchez Ramirez,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Santiago,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Santiago Rodriguez,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"Valverde,Dominican Republic "],
				[NSString stringWithFormat:@"%@",@"East Timor,East Timor "],
				[NSString stringWithFormat:@"%@",@"Azuay,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Boliar,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Canar,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Carchi,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Chimborazo,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Cotopaxi,Ecuador "],
				[NSString stringWithFormat:@"%@",@"El Oro,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Esmeraldas,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Galapagos,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Guayas,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Imbabura,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Loja,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Los Rios,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Manabi,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Morona-Santiago,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Napo,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Orellana,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Pastaza,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Pichincha,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Sucumbios,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Zamora-Chinchipe,Ecuador "],
				[NSString stringWithFormat:@"%@",@"Ad-Daqahiyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Bahr al-Ahmar,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Buhayrah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Fayyum,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Gharbiyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Iskandariyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Isma'iliyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Jizah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Minufiyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Minya,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Qahirah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Qalyubyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Al-Wadi al-Jadid,Egypt "],
				[NSString stringWithFormat:@"%@",@"As-Suways,Egypt "],
				[NSString stringWithFormat:@"%@",@"Ash-Sharqiyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Aswan,Egypt "],
				[NSString stringWithFormat:@"%@",@"Asyut,Egypt "],
				[NSString stringWithFormat:@"%@",@"Bani Suwayf,Egypt "],
				[NSString stringWithFormat:@"%@",@"Bur Sa'id,Egypt "],
				[NSString stringWithFormat:@"%@",@"Dumyat,Egypt "],
				[NSString stringWithFormat:@"%@",@"Kafr ash-Shaykh,Egypt "],
				[NSString stringWithFormat:@"%@",@"Marsa Matruh,Egypt "],
				[NSString stringWithFormat:@"%@",@"Qina,Egypt "],
				[NSString stringWithFormat:@"%@",@"Sawhaj,Egypt "],
				[NSString stringWithFormat:@"%@",@"Sina' al-Janubiyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Sina' ash-Shamaliyah,Egypt "],
				[NSString stringWithFormat:@"%@",@"Ahuachapan,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Cabanas,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Chalatenango,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Cuscatlan,El Salvador "],
				[NSString stringWithFormat:@"%@",@"La Libertad,El Salvador "],
				[NSString stringWithFormat:@"%@",@"La Paz,El Salvador "],
				[NSString stringWithFormat:@"%@",@"La Union,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Morazan,El Salvador "],
				[NSString stringWithFormat:@"%@",@"San Miguel,El Salvador "],
				[NSString stringWithFormat:@"%@",@"San Salvador,El Salvador "],
				[NSString stringWithFormat:@"%@",@"San Vicente,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Santa Ana,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Sonsonate,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Usulutan,El Salvador "],
				[NSString stringWithFormat:@"%@",@"Equatorial Guinea,Equatorial Guinea "],
				[NSString stringWithFormat:@"%@",@"Eritrea,Eritrea "],
				[NSString stringWithFormat:@"%@",@"Estonia,Estonia "],
				[NSString stringWithFormat:@"%@",@"Ethiopia,Ethiopia "],
				[NSString stringWithFormat:@"%@",@"Falkland Islands,Falkland Islands "],
				[NSString stringWithFormat:@"%@",@"Faroe Islands,Faroe Islands "],
				[NSString stringWithFormat:@"%@",@"Fiji,Fiji "],
				[NSString stringWithFormat:@"%@",@"Alands Lan,Finland "],
				[NSString stringWithFormat:@"%@",@"Lapplands Lan,Finland "],
				[NSString stringWithFormat:@"%@",@"Ostra Finlands Lan,Finland "],
				[NSString stringWithFormat:@"%@",@"Sodra Finlands Lan,Finland "],
				[NSString stringWithFormat:@"%@",@"Uleaborgs Lan,Finland "],
				[NSString stringWithFormat:@"%@",@"Vastra Finlands Lan,Finland "],
				[NSString stringWithFormat:@"%@",@"Alsace,France "],
				[NSString stringWithFormat:@"%@",@"Aquitaine,France "],
				[NSString stringWithFormat:@"%@",@"Auvergne,France "],
				[NSString stringWithFormat:@"%@",@"Basse-Normandie,France "],
				[NSString stringWithFormat:@"%@",@"Bourgogne,France "],
				[NSString stringWithFormat:@"%@",@"Bretagne,France "],
				[NSString stringWithFormat:@"%@",@"Centre,France "],
				[NSString stringWithFormat:@"%@",@"Champagne-Ardenne,France "],
				[NSString stringWithFormat:@"%@",@"Corse,France "],
				[NSString stringWithFormat:@"%@",@"Franche-Comte,France "],
				[NSString stringWithFormat:@"%@",@"Haute-Normandie,France "],
				[NSString stringWithFormat:@"%@",@"Ile-de-France,France "],
				[NSString stringWithFormat:@"%@",@"Languedoc-Roussillon,France "],
				[NSString stringWithFormat:@"%@",@"Limousin,France "],
				[NSString stringWithFormat:@"%@",@"Lorraine,France "],
				[NSString stringWithFormat:@"%@",@"Midi-Pyrenees,France "],
				[NSString stringWithFormat:@"%@",@"Nord-Pas-de-Calais,France "],
				[NSString stringWithFormat:@"%@",@"Pays-de-la Loire,France "],
				[NSString stringWithFormat:@"%@",@"Picardie,France "],
				[NSString stringWithFormat:@"%@",@"Poitou-Charentes,France "],
				[NSString stringWithFormat:@"%@",@"Provence-Alpes-Cote d'Azur,France "],
				[NSString stringWithFormat:@"%@",@"Rhooe-Alpes,France "],
				[NSString stringWithFormat:@"%@",@"Unknown,France "],
				[NSString stringWithFormat:@"%@",@"French Guiana,French Guiana "],
				[NSString stringWithFormat:@"%@",@"French Polynesia,French Polynesia "],
				[NSString stringWithFormat:@"%@",@"Gabon,Gabon "],
				[NSString stringWithFormat:@"%@",@"Gambia,Gambia "],
				[NSString stringWithFormat:@"%@",@"Georgia,Georgia "],
				[NSString stringWithFormat:@"%@",@"Baden-Wurttemberg,Germany "],
				[NSString stringWithFormat:@"%@",@"Bayern,Germany "],
				[NSString stringWithFormat:@"%@",@"Berlin,Germany "],
				[NSString stringWithFormat:@"%@",@"Brandenburg,Germany "],
				[NSString stringWithFormat:@"%@",@"Bremen,Germany "],
				[NSString stringWithFormat:@"%@",@"Hamburg,Germany "],
				[NSString stringWithFormat:@"%@",@"Hessen,Germany "],
				[NSString stringWithFormat:@"%@",@"Mecklenburg-Vorpommern,Germany "],
				[NSString stringWithFormat:@"%@",@"Niedersachsen,Germany "],
				[NSString stringWithFormat:@"%@",@"Nordrhein-Westfalen,Germany "],
				[NSString stringWithFormat:@"%@",@"Rheinland-Pfalz,Germany "],
				[NSString stringWithFormat:@"%@",@"Saarland,Germany "],
				[NSString stringWithFormat:@"%@",@"Sachsen,Germany "],
				[NSString stringWithFormat:@"%@",@"Sachsen-Anhalt,Germany "],
				[NSString stringWithFormat:@"%@",@"Schleswig-Holstein,Germany "],
				[NSString stringWithFormat:@"%@",@"Thuringen,Germany "],
				[NSString stringWithFormat:@"%@",@"Ghana,Ghana "],
				[NSString stringWithFormat:@"%@",@"Gibraltar,Gibraltar "],
				[NSString stringWithFormat:@"%@",@"Aegean Islands,Greece "],
				[NSString stringWithFormat:@"%@",@"Attiki,Greece "],
				[NSString stringWithFormat:@"%@",@"Central Greece & Evvoia,Greece "],
				[NSString stringWithFormat:@"%@",@"Crete,Greece "],
				[NSString stringWithFormat:@"%@",@"Epirus,Greece "],
				[NSString stringWithFormat:@"%@",@"Ionia Islands,Greece "],
				[NSString stringWithFormat:@"%@",@"Macedonia,Greece "],
				[NSString stringWithFormat:@"%@",@"Peloponnesus,Greece "],
				[NSString stringWithFormat:@"%@",@"Thessalia,Greece "],
				[NSString stringWithFormat:@"%@",@"Thrace,Greece "],
				[NSString stringWithFormat:@"%@",@"Greenland,Greenland "],
				[NSString stringWithFormat:@"%@",@"Grenada,Grenada "],
				[NSString stringWithFormat:@"%@",@"Guadeloupe,Guadeloupe "],
				[NSString stringWithFormat:@"%@",@"Alta Verapaz,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Baja Verapaz,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Chimaltenango,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Chiquimula,Guatemala "],
				[NSString stringWithFormat:@"%@",@"El Progreso,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Escuintla,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Guatemala,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Huehuetenango,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Izabal,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Jalapa,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Jutiapa,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Peten,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Quetzaltenango,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Quiche,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Retalhuleu,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Sacatepequez,Guatemala "],
				[NSString stringWithFormat:@"%@",@"San Marcos,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Santa Rosa,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Solola,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Suchitepequez,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Totonicapan,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Zacapa,Guatemala "],
				[NSString stringWithFormat:@"%@",@"Guernsey,Guernsey "],
				[NSString stringWithFormat:@"%@",@"Guinea,Guinea "],
				[NSString stringWithFormat:@"%@",@"Guinea-Bissau,Guinea-Bissau "],
				[NSString stringWithFormat:@"%@",@"Guyana,Guyana "],
				[NSString stringWithFormat:@"%@",@"Haiti,Haiti "],
				[NSString stringWithFormat:@"%@",@"Atlantida,Honduras "],
				[NSString stringWithFormat:@"%@",@"Choluteca,Honduras "],
				[NSString stringWithFormat:@"%@",@"Colon,Honduras "],
				[NSString stringWithFormat:@"%@",@"Comayagua,Honduras "],
				[NSString stringWithFormat:@"%@",@"Copan,Honduras "],
				[NSString stringWithFormat:@"%@",@"El Paraiso,Honduras "],
				[NSString stringWithFormat:@"%@",@"Francisco Morazan,Honduras "],
				[NSString stringWithFormat:@"%@",@"Gracias a Dios,Honduras "],
				[NSString stringWithFormat:@"%@",@"Intibuca,Honduras "],
				[NSString stringWithFormat:@"%@",@"Islas de la Bahia,Honduras "],
				[NSString stringWithFormat:@"%@",@"La Paz,Honduras "],
				[NSString stringWithFormat:@"%@",@"Lempira,Honduras "],
				[NSString stringWithFormat:@"%@",@"Ocotepeque,Honduras "],
				[NSString stringWithFormat:@"%@",@"Olancho,Honduras "],
				[NSString stringWithFormat:@"%@",@"Santa Barbara,Honduras "],
				[NSString stringWithFormat:@"%@",@"Valle,Honduras "],
				[NSString stringWithFormat:@"%@",@"Yoro,Honduras "],
				[NSString stringWithFormat:@"%@",@"Bacs-Kiskun Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Baranya Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Bekes Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Borsod-Abauj-Zemplen Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Budapest Fovaros,Hungary "],
				[NSString stringWithFormat:@"%@",@"Csongrad Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Debrecen Megyei Varos,Hungary "],
				[NSString stringWithFormat:@"%@",@"Fejer Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Gyor Megyei Varos,Hungary "],
				[NSString stringWithFormat:@"%@",@"Gyor-Moson-Sopron Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Hajdu-Bihar Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Heves Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Jasz-Nagykun-Szolnok Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Komarom-Esztergom Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Miskolc Megyei Varos,Hungary "],
				[NSString stringWithFormat:@"%@",@"Nograd Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Pecs Megyei Varos,Hungary "],
				[NSString stringWithFormat:@"%@",@"Pest Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Somogy Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Szabolcs-Szatmar-Bereg Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Szeged Megyei Varos,Hungary "],
				[NSString stringWithFormat:@"%@",@"Tolna Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Vas Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Veszprem Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Zala Megye,Hungary "],
				[NSString stringWithFormat:@"%@",@"Arnessysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Austur-Bardhastrandarsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Austur-Hunavatnssysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Austur-Skaftafellssysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Borgarfjardharsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Dalasysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Eyjafjardharsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Gullbringusysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Kjosarsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Myrasysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Nordhur-Isafjardharsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Nordhur-Mulasysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Nordhur-Thingeyjarsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Rangarvallasysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Skagafjardharsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Snaefellsnessysla- og Hnappadalssysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Strandasysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Sudhur-Mulasysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Sudhur-Thingeijjar,Iceland "],
				[NSString stringWithFormat:@"%@",@"Vestur-Bardhastrandarsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Vestur-Hunavatnssysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Vestur-Isafjardharsysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Vestur-Skaftafellssysla,Iceland "],
				[NSString stringWithFormat:@"%@",@"Andaman & Nicobar Islands,India "],
				[NSString stringWithFormat:@"%@",@"Andhra Pradesh,India "],
				[NSString stringWithFormat:@"%@",@"Arunachal Pradesh,India "],
				[NSString stringWithFormat:@"%@",@"Assam,India "],
				[NSString stringWithFormat:@"%@",@"Bihar,India "],
				[NSString stringWithFormat:@"%@",@"Chandigarh,India "],
				[NSString stringWithFormat:@"%@",@"Dadra & Nagar Haveli,India "],
				[NSString stringWithFormat:@"%@",@"Delhi,India "],
				[NSString stringWithFormat:@"%@",@"Goa,India "],
				[NSString stringWithFormat:@"%@",@"Gujarat,India "],
				[NSString stringWithFormat:@"%@",@"Haryana,India "],
				[NSString stringWithFormat:@"%@",@"Himachal Pradesh,India "],
				[NSString stringWithFormat:@"%@",@"Jammu & Kashmir,India "],
				[NSString stringWithFormat:@"%@",@"Jharkhand,India "],
				[NSString stringWithFormat:@"%@",@"Karnataka,India "],
				[NSString stringWithFormat:@"%@",@"Kerala,India "],
				[NSString stringWithFormat:@"%@",@"Lakshadweep,India "],
				[NSString stringWithFormat:@"%@",@"Madhya Pradesh,India "],
				[NSString stringWithFormat:@"%@",@"Maharashtra,India "],
				[NSString stringWithFormat:@"%@",@"Manipur,India "],
				[NSString stringWithFormat:@"%@",@"Meghalaya,India "],
				[NSString stringWithFormat:@"%@",@"Mizoram,India "],
				[NSString stringWithFormat:@"%@",@"Nagaland,India "],
				[NSString stringWithFormat:@"%@",@"Orissa,India "],
				[NSString stringWithFormat:@"%@",@"Pondicherry,India "],
				[NSString stringWithFormat:@"%@",@"Punjab,India "],
				[NSString stringWithFormat:@"%@",@"Rajasthan,India "],
				[NSString stringWithFormat:@"%@",@"Sikkim,India "],
				[NSString stringWithFormat:@"%@",@"Tamil Nadu,India "],
				[NSString stringWithFormat:@"%@",@"Tripura,India "],
				[NSString stringWithFormat:@"%@",@"Uttar Pradesh,India "],
				[NSString stringWithFormat:@"%@",@"Uttaranchal,India "],
				[NSString stringWithFormat:@"%@",@"West Bengal,India "],
				[NSString stringWithFormat:@"%@",@"Aceh,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Bali,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Bengkulu,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Jambi,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Jawa Barat,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Jawa Tengah,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Jawa Timur,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Kalimantan Barat,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Kalimantan Selatan,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Kalimantan Tengah,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Kalimantan Timur,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Lampung,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Maluku,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Nusa Tenggara Barat,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Nusa Tenggara Timur,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Papua,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Riau,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Sulawesi Selatan,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Sulawesi Tengah,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Sulawesi Tenggara,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Sulawesi Utara,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Sumatera Barat,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Sumatera Utara,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Unknown,Indonesia "],
				[NSString stringWithFormat:@"%@",@"Yogyakarta,Indonesia "],
				[NSString stringWithFormat:@"%@",@"a Baluchestan,Iran "],
				[NSString stringWithFormat:@"%@",@"ahall va Bakhtiari,Iran "],
				[NSString stringWithFormat:@"%@",@"an-e Gharbi,Iran "],
				[NSString stringWithFormat:@"%@",@"an-e Sharqi,Iran "],
				[NSString stringWithFormat:@"%@",@"eh va Buyer Ahmad,Iran "],
				[NSString stringWithFormat:@"%@",@"n,Iran "],
				[NSString stringWithFormat:@"%@",@"n,Iran "],
				[NSString stringWithFormat:@"%@",@"n,Iran "],
				[NSString stringWithFormat:@"%@",@"Anbar,Iraq "],
				[NSString stringWithFormat:@"%@",@"Arbil,Iraq "],
				[NSString stringWithFormat:@"%@",@"Babil,Iraq "],
				[NSString stringWithFormat:@"%@",@"Baghdad,Iraq "],
				[NSString stringWithFormat:@"%@",@"Basrah,Iraq "],
				[NSString stringWithFormat:@"%@",@"Dahuk,Iraq "],
				[NSString stringWithFormat:@"%@",@"Dhi Qar,Iraq "],
				[NSString stringWithFormat:@"%@",@"Diyala,Iraq "],
				[NSString stringWithFormat:@"%@",@"Karbala',Iraq "],
				[NSString stringWithFormat:@"%@",@"Maysan,Iraq "],
				[NSString stringWithFormat:@"%@",@"Muthanna,Iraq "],
				[NSString stringWithFormat:@"%@",@"Najaf,Iraq "],
				[NSString stringWithFormat:@"%@",@"Ninawa,Iraq "],
				[NSString stringWithFormat:@"%@",@"Qadisiyah,Iraq "],
				[NSString stringWithFormat:@"%@",@"Salah ad Din,Iraq "],
				[NSString stringWithFormat:@"%@",@"Sulaymaniyah,Iraq "],
				[NSString stringWithFormat:@"%@",@"Ta'mim,Iraq "],
				[NSString stringWithFormat:@"%@",@"Wasit,Iraq "],
				[NSString stringWithFormat:@"%@",@"Carlow,Ireland "],
				[NSString stringWithFormat:@"%@",@"Cavan,Ireland "],
				[NSString stringWithFormat:@"%@",@"Clare,Ireland "],
				[NSString stringWithFormat:@"%@",@"Cork,Ireland "],
				[NSString stringWithFormat:@"%@",@"Donegal,Ireland "],
				[NSString stringWithFormat:@"%@",@"Dublin,Ireland "],
				[NSString stringWithFormat:@"%@",@"Galway,Ireland "],
				[NSString stringWithFormat:@"%@",@"Kerry,Ireland "],
				[NSString stringWithFormat:@"%@",@"Kildare,Ireland "],
				[NSString stringWithFormat:@"%@",@"Kilkenny,Ireland "],
				[NSString stringWithFormat:@"%@",@"Laois,Ireland "],
				[NSString stringWithFormat:@"%@",@"Leitrim,Ireland "],
				[NSString stringWithFormat:@"%@",@"Limerick,Ireland "],
				[NSString stringWithFormat:@"%@",@"Longford,Ireland "],
				[NSString stringWithFormat:@"%@",@"Louth,Ireland "],
				[NSString stringWithFormat:@"%@",@"Mayo,Ireland "],
				[NSString stringWithFormat:@"%@",@"Meath,Ireland "],
				[NSString stringWithFormat:@"%@",@"Monaghan,Ireland "],
				[NSString stringWithFormat:@"%@",@"Offaly,Ireland "],
				[NSString stringWithFormat:@"%@",@"Roscommon,Ireland "],
				[NSString stringWithFormat:@"%@",@"Sligo,Ireland "],
				[NSString stringWithFormat:@"%@",@"Tipperary,Ireland "],
				[NSString stringWithFormat:@"%@",@"Unknown,Ireland "],
				[NSString stringWithFormat:@"%@",@"Waterford,Ireland "],
				[NSString stringWithFormat:@"%@",@"Westmeath,Ireland "],
				[NSString stringWithFormat:@"%@",@"Wexford,Ireland "],
				[NSString stringWithFormat:@"%@",@"Wicklow,Ireland "],
				[NSString stringWithFormat:@"%@",@"Isle of Man,Isle of Man "],
				[NSString stringWithFormat:@"%@",@"Central District,Israel "],
				[NSString stringWithFormat:@"%@",@"Haifa District,Israel "],
				[NSString stringWithFormat:@"%@",@"Jerusalem District,Israel "],
				[NSString stringWithFormat:@"%@",@"Northern District,Israel "],
				[NSString stringWithFormat:@"%@",@"Southern District,Israel "],
				[NSString stringWithFormat:@"%@",@"Tel Aviv District,Israel "],
				[NSString stringWithFormat:@"%@",@"Abruzzi,Italy "],
				[NSString stringWithFormat:@"%@",@"Basilicata,Italy "],
				[NSString stringWithFormat:@"%@",@"Calabria,Italy "],
				[NSString stringWithFormat:@"%@",@"Campania,Italy "],
				[NSString stringWithFormat:@"%@",@"Emilia-Romagna,Italy "],
				[NSString stringWithFormat:@"%@",@"Friuli-Venezia Giulia,Italy "],
				[NSString stringWithFormat:@"%@",@"Lazio,Italy "],
				[NSString stringWithFormat:@"%@",@"Liguria,Italy "],
				[NSString stringWithFormat:@"%@",@"Lombardia,Italy "],
				[NSString stringWithFormat:@"%@",@"Marche,Italy "],
				[NSString stringWithFormat:@"%@",@"Molise,Italy "],
				[NSString stringWithFormat:@"%@",@"Piemonte,Italy "],
				[NSString stringWithFormat:@"%@",@"Puglia,Italy "],
				[NSString stringWithFormat:@"%@",@"Sardegna,Italy "],
				[NSString stringWithFormat:@"%@",@"Sicilia,Italy "],
				[NSString stringWithFormat:@"%@",@"Toscana,Italy "],
				[NSString stringWithFormat:@"%@",@"Trentino-Alto Adige,Italy "],
				[NSString stringWithFormat:@"%@",@"Umbria,Italy "],
				[NSString stringWithFormat:@"%@",@"Valle d'Aosta,Italy "],
				[NSString stringWithFormat:@"%@",@"Veneto,Italy "],
				[NSString stringWithFormat:@"%@",@"Clarendon,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Hanover,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Kingston,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Manchester,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Portland,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Saint Andrews,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Saint Ann,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Saint Catherine,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Saint Elizabeth,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Saint James,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Saint Mary,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Saint Thomas,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Trelawny,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Westmoreland,Jamaica "],
				[NSString stringWithFormat:@"%@",@"Aichi,Japan "],
				[NSString stringWithFormat:@"%@",@"Akita,Japan "],
				[NSString stringWithFormat:@"%@",@"Aomori,Japan "],
				[NSString stringWithFormat:@"%@",@"Chiba,Japan "],
				[NSString stringWithFormat:@"%@",@"Ehime,Japan "],
				[NSString stringWithFormat:@"%@",@"Fukui,Japan "],
				[NSString stringWithFormat:@"%@",@"Fukuoka,Japan "],
				[NSString stringWithFormat:@"%@",@"Fukushima,Japan "],
				[NSString stringWithFormat:@"%@",@"Gifu,Japan "],
				[NSString stringWithFormat:@"%@",@"Gumma,Japan "],
				[NSString stringWithFormat:@"%@",@"Hiroshima,Japan "],
				[NSString stringWithFormat:@"%@",@"Hokkaido,Japan "],
				[NSString stringWithFormat:@"%@",@"Hyogo,Japan "],
				[NSString stringWithFormat:@"%@",@"Ibaraki,Japan "],
				[NSString stringWithFormat:@"%@",@"Ishikawa,Japan "],
				[NSString stringWithFormat:@"%@",@"Iwate,Japan "],
				[NSString stringWithFormat:@"%@",@"Kagawa,Japan "],
				[NSString stringWithFormat:@"%@",@"Kagoshima,Japan "],
				[NSString stringWithFormat:@"%@",@"Kanagawa,Japan "],
				[NSString stringWithFormat:@"%@",@"Kochi,Japan "],
				[NSString stringWithFormat:@"%@",@"Kumamoto,Japan "],
				[NSString stringWithFormat:@"%@",@"Kyoto,Japan "],
				[NSString stringWithFormat:@"%@",@"Mie,Japan "],
				[NSString stringWithFormat:@"%@",@"Miyagi,Japan "],
				[NSString stringWithFormat:@"%@",@"Miyazaki,Japan "],
				[NSString stringWithFormat:@"%@",@"Nagano,Japan "],
				[NSString stringWithFormat:@"%@",@"Nagasaki,Japan "],
				[NSString stringWithFormat:@"%@",@"Nara,Japan "],
				[NSString stringWithFormat:@"%@",@"Niigata,Japan "],
				[NSString stringWithFormat:@"%@",@"Oita,Japan "],
				[NSString stringWithFormat:@"%@",@"Okayama,Japan "],
				[NSString stringWithFormat:@"%@",@"Okinawa,Japan "],
				[NSString stringWithFormat:@"%@",@"Osaka,Japan "],
				[NSString stringWithFormat:@"%@",@"Saga,Japan "],
				[NSString stringWithFormat:@"%@",@"Saitama,Japan "],
				[NSString stringWithFormat:@"%@",@"Shiga,Japan "],
				[NSString stringWithFormat:@"%@",@"Shimane,Japan "],
				[NSString stringWithFormat:@"%@",@"Shizuoka,Japan "],
				[NSString stringWithFormat:@"%@",@"Tochigi,Japan "],
				[NSString stringWithFormat:@"%@",@"Tokushima,Japan "],
				[NSString stringWithFormat:@"%@",@"Tokyo,Japan "],
				[NSString stringWithFormat:@"%@",@"Tottori,Japan "],
				[NSString stringWithFormat:@"%@",@"Toyama,Japan "],
				[NSString stringWithFormat:@"%@",@"Wakayama,Japan "],
				[NSString stringWithFormat:@"%@",@"Yamagata,Japan "],
				[NSString stringWithFormat:@"%@",@"Yamaguchi,Japan "],
				[NSString stringWithFormat:@"%@",@"Yamanashi,Japan "],
				[NSString stringWithFormat:@"%@",@"Jersey,Jersey "],
				[NSString stringWithFormat:@"%@",@"Jordan,Jordan "],
				[NSString stringWithFormat:@"%@",@"Kazakhstan,Kazakhstan "],
				[NSString stringWithFormat:@"%@",@"Central,Kenya "],
				[NSString stringWithFormat:@"%@",@"Coast,Kenya "],
				[NSString stringWithFormat:@"%@",@"Eastern,Kenya "],
				[NSString stringWithFormat:@"%@",@"Nairobi,Kenya "],
				[NSString stringWithFormat:@"%@",@"North Eastern,Kenya "],
				[NSString stringWithFormat:@"%@",@"Nyanza,Kenya "],
				[NSString stringWithFormat:@"%@",@"Rift Valley,Kenya "],
				[NSString stringWithFormat:@"%@",@"Western,Kenya "],
				[NSString stringWithFormat:@"%@",@"Kiribati,Kiribati "],
				[NSString stringWithFormat:@"%@",@"Al-Ahmadi,Kuwait "],
				[NSString stringWithFormat:@"%@",@"Al-Farwaniyah,Kuwait "],
				[NSString stringWithFormat:@"%@",@"Al-Kuwayt,Kuwait "],
				[NSString stringWithFormat:@"%@",@"Bubiyan & Warbah,Kuwait "],
				[NSString stringWithFormat:@"%@",@"Hawalli,Kuwait "],
				[NSString stringWithFormat:@"%@",@"Kyrgyzstan,Kyrgyzstan "],
				[NSString stringWithFormat:@"%@",@"Laos,Laos "],
				[NSString stringWithFormat:@"%@",@"Latvia,Latvia "],
				[NSString stringWithFormat:@"%@",@"Lebanon,Lebanon "],
				[NSString stringWithFormat:@"%@",@"Lesotho,Lesotho "],
				[NSString stringWithFormat:@"%@",@"Liberia,Liberia "],
				[NSString stringWithFormat:@"%@",@"Libya,Libya "],
				[NSString stringWithFormat:@"%@",@"Liechtenstein,Liechtenstein "],
				[NSString stringWithFormat:@"%@",@"Lithuania,Lithuania "],
				[NSString stringWithFormat:@"%@",@"Luxembourg,Luxembourg "],
				[NSString stringWithFormat:@"%@",@"Macau,Macau "],
				[NSString stringWithFormat:@"%@",@"Macedonia,Macedonia "],
				[NSString stringWithFormat:@"%@",@"Antananarivo,Madagascar "],
				[NSString stringWithFormat:@"%@",@"Antsiranana,Madagascar "],
				[NSString stringWithFormat:@"%@",@"Fianarantsoa,Madagascar "],
				[NSString stringWithFormat:@"%@",@"Mahajanga,Madagascar "],
				[NSString stringWithFormat:@"%@",@"Toamasina,Madagascar "],
				[NSString stringWithFormat:@"%@",@"Toliary,Madagascar "],
				[NSString stringWithFormat:@"%@",@"Malawi,Malawi "],
				[NSString stringWithFormat:@"%@",@"Johor,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Kedah,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Kelantan,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Melaka,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Pahang,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Perak,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Perlis,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Pulau Pinang,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Sabah,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Sarawak,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Selangor,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Sembilan,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Terengganu,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Unknown,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Wilayah Persekutuan,Malaysia "],
				[NSString stringWithFormat:@"%@",@"Maldives,Maldives "],
				[NSString stringWithFormat:@"%@",@"Mali,Mali "],
				[NSString stringWithFormat:@"%@",@"Malta,Malta "],
				[NSString stringWithFormat:@"%@",@"Marshall Islands,Marshall Islands "],
				[NSString stringWithFormat:@"%@",@"Martinique,Martinique "],
				[NSString stringWithFormat:@"%@",@"Mauritania,Mauritania "],
				[NSString stringWithFormat:@"%@",@"Mauritius,Mauritius "],
				[NSString stringWithFormat:@"%@",@"Mayotte,Mayotte "],
				[NSString stringWithFormat:@"%@",@"Aguascalientes,Mexico "],
				[NSString stringWithFormat:@"%@",@"Baja California,Mexico "],
				[NSString stringWithFormat:@"%@",@"Baja California Sur,Mexico "],
				[NSString stringWithFormat:@"%@",@"Campeche,Mexico "],
				[NSString stringWithFormat:@"%@",@"Chiapas,Mexico "],
				[NSString stringWithFormat:@"%@",@"Chihuahua,Mexico "],
				[NSString stringWithFormat:@"%@",@"Coahuila,Mexico "],
				[NSString stringWithFormat:@"%@",@"Colima,Mexico "],
				[NSString stringWithFormat:@"%@",@"Distrito Federal,Mexico "],
				[NSString stringWithFormat:@"%@",@"Durango,Mexico "],
				[NSString stringWithFormat:@"%@",@"Guanajuato,Mexico "],
				[NSString stringWithFormat:@"%@",@"Guerrero,Mexico "],
				[NSString stringWithFormat:@"%@",@"Hidalgo,Mexico "],
				[NSString stringWithFormat:@"%@",@"Jalisco,Mexico "],
				[NSString stringWithFormat:@"%@",@"Mexico,Mexico "],
				[NSString stringWithFormat:@"%@",@"Michoacan de Ocampo,Mexico "],
				[NSString stringWithFormat:@"%@",@"Morelos,Mexico "],
				[NSString stringWithFormat:@"%@",@"Nayarit,Mexico "],
				[NSString stringWithFormat:@"%@",@"Nuevo Leon,Mexico "],
				[NSString stringWithFormat:@"%@",@"Oaxaca,Mexico "],
				[NSString stringWithFormat:@"%@",@"Puebla,Mexico "],
				[NSString stringWithFormat:@"%@",@"Queretaro de Arteaga,Mexico "],
				[NSString stringWithFormat:@"%@",@"Quintana Roo,Mexico "],
				[NSString stringWithFormat:@"%@",@"San Luis Potosi,Mexico "],
				[NSString stringWithFormat:@"%@",@"Sinaloa,Mexico "],
				[NSString stringWithFormat:@"%@",@"Sonora,Mexico "],
				[NSString stringWithFormat:@"%@",@"Tabasco,Mexico "],
				[NSString stringWithFormat:@"%@",@"Tamaulipas,Mexico "],
				[NSString stringWithFormat:@"%@",@"Tlaxcala,Mexico "],
				[NSString stringWithFormat:@"%@",@"Veracruz-Llave,Mexico "],
				[NSString stringWithFormat:@"%@",@"Yucatan,Mexico "],
				[NSString stringWithFormat:@"%@",@"Zacatecas,Mexico "],
				[NSString stringWithFormat:@"%@",@"Micronesia,Micronesia "],
				[NSString stringWithFormat:@"%@",@"Moldova,Moldova "],
				[NSString stringWithFormat:@"%@",@"Monaco,Monaco "],
				[NSString stringWithFormat:@"%@",@"Mongolia,Mongolia "],
				[NSString stringWithFormat:@"%@",@"Montserrat,Montserrat "],
				[NSString stringWithFormat:@"%@",@"Chaouia-Ouardigha,Morocco "],
				[NSString stringWithFormat:@"%@",@"Doukkala-Abda,Morocco "],
				[NSString stringWithFormat:@"%@",@"Fes-Boulemane,Morocco "],
				[NSString stringWithFormat:@"%@",@"Gharb-Chrarda-Beni Hsen,Morocco "],
				[NSString stringWithFormat:@"%@",@"Grand Casablanca,Morocco "],
				[NSString stringWithFormat:@"%@",@"Marrakech-Tensift-El Haouz,Morocco "],
				[NSString stringWithFormat:@"%@",@"Meknes-Tafilalt,Morocco "],
				[NSString stringWithFormat:@"%@",@"Rabat-Sale-Zemmour-Zaer,Morocco "],
				[NSString stringWithFormat:@"%@",@"Sous-Massa-Draa,Morocco "],
				[NSString stringWithFormat:@"%@",@"Tanger-Tetouan,Morocco "],
				[NSString stringWithFormat:@"%@",@"Taza-Al Hoceima-Taounate,Morocco "],
				[NSString stringWithFormat:@"%@",@"Mozambique,Mozambique "],
				[NSString stringWithFormat:@"%@",@"Ayeyarwady,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Bago,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Chin,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Kachin,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Kayah,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Kayin,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Magway,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Mandalay,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Mon,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Rakhine,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Sagaing,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Shan,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Tanintharyi,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Unknown,Myanmar "],
				[NSString stringWithFormat:@"%@",@"Namibia,Namibia "],
				[NSString stringWithFormat:@"%@",@"Nauru,Nauru "],
				[NSString stringWithFormat:@"%@",@"Nepal,Nepal "],
				[NSString stringWithFormat:@"%@",@"Drenthe,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Flevoland,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Friesland,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Gelderland,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Groningen,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Limburg,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Noord-Brabant,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Noord-Holland,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Overijssel,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Utrecht,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Zeeland,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Zuid-Holland,Netherlands "],
				[NSString stringWithFormat:@"%@",@"Netherlands Antilles,Netherlands Antilles "],
				[NSString stringWithFormat:@"%@",@"New Caledonia,New Caledonia "],
				[NSString stringWithFormat:@"%@",@"Chatham Islands,New Zealand "],
				[NSString stringWithFormat:@"%@",@"North Island,New Zealand "],
				[NSString stringWithFormat:@"%@",@"South Island,New Zealand "],
				[NSString stringWithFormat:@"%@",@"Stewart Island,New Zealand "],
				[NSString stringWithFormat:@"%@",@"Atlantico Norte,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Atlantico Sur,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Boaco,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Carazo,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Chinandega,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Chontales,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Esteli,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Granada,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Jinotega,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Leon,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Madriz,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Managua,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Masaya,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Matagalpa,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Nueva Segovia,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Rio San Juan,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Rivas,Nicaragua "],
				[NSString stringWithFormat:@"%@",@"Agadez,Niger "],
				[NSString stringWithFormat:@"%@",@"Diffa,Niger "],
				[NSString stringWithFormat:@"%@",@"Dosso,Niger "],
				[NSString stringWithFormat:@"%@",@"Maradi,Niger "],
				[NSString stringWithFormat:@"%@",@"Niamey,Niger "],
				[NSString stringWithFormat:@"%@",@"Tahoua,Niger "],
				[NSString stringWithFormat:@"%@",@"Tillaberi,Niger "],
				[NSString stringWithFormat:@"%@",@"Zinder,Niger "],
				[NSString stringWithFormat:@"%@",@"Abuja,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Adamawa,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Bauchi,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Benue,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Borno,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Delta,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Gombe,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Gongola,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Jigawa,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Kaduna,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Kano,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Katsina,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Kwara,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Lagos,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Nassarawa,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Niger,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Ogun,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Oyo,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Plateau,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Sokoto,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Unknown,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Zamfara,Nigeria "],
				[NSString stringWithFormat:@"%@",@"Niue,Niue "],
				[NSString stringWithFormat:@"%@",@"Norfolk Island,Norfolk Island "],
				[NSString stringWithFormat:@"%@",@"Chagang-do,North Korea "],
				[NSString stringWithFormat:@"%@",@"Hamgyong-bukto,North Korea "],
				[NSString stringWithFormat:@"%@",@"Hamgyong-namdo,North Korea "],
				[NSString stringWithFormat:@"%@",@"Hwanghae-bukto,North Korea "],
				[NSString stringWithFormat:@"%@",@"Hwanghae-namdo,North Korea "],
				[NSString stringWithFormat:@"%@",@"Kaesong-si,North Korea "],
				[NSString stringWithFormat:@"%@",@"Kangwon-do,North Korea "],
				[NSString stringWithFormat:@"%@",@"Najin Sonbong-si,North Korea "],
				[NSString stringWithFormat:@"%@",@"Namp'o-si,North Korea "],
				[NSString stringWithFormat:@"%@",@"P'yongan-bukto,North Korea "],
				[NSString stringWithFormat:@"%@",@"P'yongan-namdo,North Korea "],
				[NSString stringWithFormat:@"%@",@"P'yongyang-si,North Korea "],
				[NSString stringWithFormat:@"%@",@"Yanggang-do,North Korea "],
				[NSString stringWithFormat:@"%@",@"Akershus,Norway "],
				[NSString stringWithFormat:@"%@",@"Aust-Agder,Norway "],
				[NSString stringWithFormat:@"%@",@"Buskerud,Norway "],
				[NSString stringWithFormat:@"%@",@"Finnmark,Norway "],
				[NSString stringWithFormat:@"%@",@"Hedmark,Norway "],
				[NSString stringWithFormat:@"%@",@"Hordaland,Norway "],
				[NSString stringWithFormat:@"%@",@"More og Romsdal,Norway "],
				[NSString stringWithFormat:@"%@",@"Nord-Trondelag,Norway "],
				[NSString stringWithFormat:@"%@",@"Nordland,Norway "],
				[NSString stringWithFormat:@"%@",@"Oppland,Norway "],
				[NSString stringWithFormat:@"%@",@"Oslo,Norway "],
				[NSString stringWithFormat:@"%@",@"Ostfold,Norway "],
				[NSString stringWithFormat:@"%@",@"Rogaland,Norway "],
				[NSString stringWithFormat:@"%@",@"Sogn og Fjordane,Norway "],
				[NSString stringWithFormat:@"%@",@"Sor-Trondelag,Norway "],
				[NSString stringWithFormat:@"%@",@"Telemark,Norway "],
				[NSString stringWithFormat:@"%@",@"Troms,Norway "],
				[NSString stringWithFormat:@"%@",@"Vest-Agder,Norway "],
				[NSString stringWithFormat:@"%@",@"Vestfold,Norway "],
				[NSString stringWithFormat:@"%@",@"Oman,Oman "],
				[NSString stringWithFormat:@"%@",@"Balochistan,Pakistan "],
				[NSString stringWithFormat:@"%@",@"Federally Administered Tribal Areas,Pakistan "],
				[NSString stringWithFormat:@"%@",@"Islamabad Capital Territory,Pakistan "],
				[NSString stringWithFormat:@"%@",@"North-West Frontier Province,Pakistan "],
				[NSString stringWithFormat:@"%@",@"Punjab,Pakistan "],
				[NSString stringWithFormat:@"%@",@"Sind,Pakistan "],
				[NSString stringWithFormat:@"%@",@"Palau,Palau "],
				[NSString stringWithFormat:@"%@",@"Bocas del Toro,Panama "],
				[NSString stringWithFormat:@"%@",@"Chiriqui,Panama "],
				[NSString stringWithFormat:@"%@",@"Colon,Panama "],
				[NSString stringWithFormat:@"%@",@"Darien,Panama "],
				[NSString stringWithFormat:@"%@",@"Herrera,Panama "],
				[NSString stringWithFormat:@"%@",@"Kuna Yala,Panama "],
				[NSString stringWithFormat:@"%@",@"Los Santos,Panama "],
				[NSString stringWithFormat:@"%@",@"Panama,Panama "],
				[NSString stringWithFormat:@"%@",@"Veraguas,Panama "],
				[NSString stringWithFormat:@"%@",@"Papua New Guinea,Papua New Guinea "],
				[NSString stringWithFormat:@"%@",@"Alto Paraguay,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Alto Parana,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Amambay,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Boqueron,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Caaguazu,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Caazapa,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Canindeyu,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Central,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Concepcion,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Cordillera,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Guaira,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Itapua,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Misiones,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Neembucu,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Paraguari,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Presidente Hayes,Paraguay "],
				[NSString stringWithFormat:@"%@",@"San Pedro,Paraguay "],
				[NSString stringWithFormat:@"%@",@"Amazonas,Peru "],
				[NSString stringWithFormat:@"%@",@"Ancash,Peru "],
				[NSString stringWithFormat:@"%@",@"Apurimac,Peru "],
				[NSString stringWithFormat:@"%@",@"Arequipa,Peru "],
				[NSString stringWithFormat:@"%@",@"Ayacucho,Peru "],
				[NSString stringWithFormat:@"%@",@"Cajamarca,Peru "],
				[NSString stringWithFormat:@"%@",@"Callao,Peru "],
				[NSString stringWithFormat:@"%@",@"Cusco,Peru "],
				[NSString stringWithFormat:@"%@",@"Huancavelica,Peru "],
				[NSString stringWithFormat:@"%@",@"Huanuco,Peru "],
				[NSString stringWithFormat:@"%@",@"Ica,Peru "],
				[NSString stringWithFormat:@"%@",@"Junin,Peru "],
				[NSString stringWithFormat:@"%@",@"La Libertad,Peru "],
				[NSString stringWithFormat:@"%@",@"Lambayeque,Peru "],
				[NSString stringWithFormat:@"%@",@"Lima,Peru "],
				[NSString stringWithFormat:@"%@",@"Loreto,Peru "],
				[NSString stringWithFormat:@"%@",@"Madre de Dios,Peru "],
				[NSString stringWithFormat:@"%@",@"Moquegua,Peru "],
				[NSString stringWithFormat:@"%@",@"Pasco,Peru "],
				[NSString stringWithFormat:@"%@",@"Piura,Peru "],
				[NSString stringWithFormat:@"%@",@"Puno,Peru "],
				[NSString stringWithFormat:@"%@",@"San Martin,Peru "],
				[NSString stringWithFormat:@"%@",@"Tacna,Peru "],
				[NSString stringWithFormat:@"%@",@"Tumbes,Peru "],
				[NSString stringWithFormat:@"%@",@"Ucayali,Peru "],
				[NSString stringWithFormat:@"%@",@"Abra,Philippines "],
				[NSString stringWithFormat:@"%@",@"Agusan del Norte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Agusan del Sur,Philippines "],
				[NSString stringWithFormat:@"%@",@"Aklan,Philippines "],
				[NSString stringWithFormat:@"%@",@"Albay,Philippines "],
				[NSString stringWithFormat:@"%@",@"Angeles City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Antique,Philippines "],
				[NSString stringWithFormat:@"%@",@"Aurora,Philippines "],
				[NSString stringWithFormat:@"%@",@"Bacolod City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Bago City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Baguio City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Basilan,Philippines "],
				[NSString stringWithFormat:@"%@",@"Bataan,Philippines "],
				[NSString stringWithFormat:@"%@",@"Batanes,Philippines "],
				[NSString stringWithFormat:@"%@",@"Batangas,Philippines "],
				[NSString stringWithFormat:@"%@",@"Batangas City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Benguet,Philippines "],
				[NSString stringWithFormat:@"%@",@"Bohol,Philippines "],
				[NSString stringWithFormat:@"%@",@"Bukidnon,Philippines "],
				[NSString stringWithFormat:@"%@",@"Bulacan,Philippines "],
				[NSString stringWithFormat:@"%@",@"Butuan City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cabanatuan City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cadiz City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cagayan,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cagayan de Oro City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Calbayog City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Caloocan City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Camarines Norte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Camarines Sur,Philippines "],
				[NSString stringWithFormat:@"%@",@"Camiguin,Philippines "],
				[NSString stringWithFormat:@"%@",@"Canlaon City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Capiz,Philippines "],
				[NSString stringWithFormat:@"%@",@"Catanduanes,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cavite,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cavite City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cebu,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cebu City,Philippines "],
				[NSString stringWithFormat:@"%@",@"City of Manila,Philippines "],
				[NSString stringWithFormat:@"%@",@"Cotabato City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Dagupan City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Danao City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Dapitan City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Davao City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Davao del Norte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Davao del Sur,Philippines "],
				[NSString stringWithFormat:@"%@",@"Davao Oriental,Philippines "],
				[NSString stringWithFormat:@"%@",@"Dipolog City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Dumaguete City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Eastern Samar,Philippines "],
				[NSString stringWithFormat:@"%@",@"General Santos City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Gingoog City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Ifugao,Philippines "],
				[NSString stringWithFormat:@"%@",@"Iligan City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Ilocos Norte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Ilocos Sur,Philippines "],
				[NSString stringWithFormat:@"%@",@"Iloilo,Philippines "],
				[NSString stringWithFormat:@"%@",@"Iloilo City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Iriga City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Isabela,Philippines "],
				[NSString stringWithFormat:@"%@",@"Kalinga-Apayao,Philippines "],
				[NSString stringWithFormat:@"%@",@"La Carlota City,Philippines "],
				[NSString stringWithFormat:@"%@",@"La Union,Philippines "],
				[NSString stringWithFormat:@"%@",@"Laguna,Philippines "],
				[NSString stringWithFormat:@"%@",@"Lanao del Norte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Lanao del Sur,Philippines "],
				[NSString stringWithFormat:@"%@",@"Laoag City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Lapu-Lapu City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Legaspi City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Leyte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Lipa City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Lucena City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Maguindanao,Philippines "],
				[NSString stringWithFormat:@"%@",@"Mandaue City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Marawi City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Marinduque,Philippines "],
				[NSString stringWithFormat:@"%@",@"Masbate,Philippines "],
				[NSString stringWithFormat:@"%@",@"Mindoro Occidental,Philippines "],
				[NSString stringWithFormat:@"%@",@"Mindoro Oriental,Philippines "],
				[NSString stringWithFormat:@"%@",@"Misamis Occidental,Philippines "],
				[NSString stringWithFormat:@"%@",@"Misamis Oriental,Philippines "],
				[NSString stringWithFormat:@"%@",@"Mountain Province,Philippines "],
				[NSString stringWithFormat:@"%@",@"Naga City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Negros Occidental,Philippines "],
				[NSString stringWithFormat:@"%@",@"Negros Oriental,Philippines "],
				[NSString stringWithFormat:@"%@",@"North Cotabato,Philippines "],
				[NSString stringWithFormat:@"%@",@"Northern Samar,Philippines "],
				[NSString stringWithFormat:@"%@",@"Nueva Ecija,Philippines "],
				[NSString stringWithFormat:@"%@",@"Nueva Vizcaya,Philippines "],
				[NSString stringWithFormat:@"%@",@"Olongapo City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Ormoc City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Oroquieta City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Ozamis City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Pagadian City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Palawan,Philippines "],
				[NSString stringWithFormat:@"%@",@"Palayan City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Pampanga,Philippines "],
				[NSString stringWithFormat:@"%@",@"Pangasinan,Philippines "],
				[NSString stringWithFormat:@"%@",@"Pasay City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Puerto Princesa City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Quezon,Philippines "],
				[NSString stringWithFormat:@"%@",@"Quezon City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Quirino,Philippines "],
				[NSString stringWithFormat:@"%@",@"Rizal,Philippines "],
				[NSString stringWithFormat:@"%@",@"Romblon,Philippines "],
				[NSString stringWithFormat:@"%@",@"Roxas City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Samar,Philippines "],
				[NSString stringWithFormat:@"%@",@"San Carlos City,Philippines "],
				[NSString stringWithFormat:@"%@",@"San Pablo City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Silay City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Siquijor,Philippines "],
				[NSString stringWithFormat:@"%@",@"Sorsogon,Philippines "],
				[NSString stringWithFormat:@"%@",@"South Cotabato,Philippines "],
				[NSString stringWithFormat:@"%@",@"Southern Leyte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Sultan Kudarat,Philippines "],
				[NSString stringWithFormat:@"%@",@"Sulu,Philippines "],
				[NSString stringWithFormat:@"%@",@"Surigao City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Surigao del Norte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Surigao del Sur,Philippines "],
				[NSString stringWithFormat:@"%@",@"Tacloban City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Tagaytay City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Tagbilaran City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Tangub City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Tarlac,Philippines "],
				[NSString stringWithFormat:@"%@",@"Tawi-Tawi,Philippines "],
				[NSString stringWithFormat:@"%@",@"Toledo City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Trece Martires City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Zambales,Philippines "],
				[NSString stringWithFormat:@"%@",@"Zamboanga City,Philippines "],
				[NSString stringWithFormat:@"%@",@"Zamboanga del Norte,Philippines "],
				[NSString stringWithFormat:@"%@",@"Zamboanga del Sur,Philippines "],
				[NSString stringWithFormat:@"%@",@"Pitcairn Islands,Pitcairn Islands "],
				[NSString stringWithFormat:@"%@",@"Dolnoslaskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Kujawsko-Pomorskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Lodzkie,Poland "],
				[NSString stringWithFormat:@"%@",@"Lubelskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Lubuskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Malopolskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Mazowieckie,Poland "],
				[NSString stringWithFormat:@"%@",@"Opolskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Podkarpackie,Poland "],
				[NSString stringWithFormat:@"%@",@"Podlaskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Pomorskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Slaskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Swietokrzyskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Warminsko-Mazurskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Wielkopolskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Zachodniopomorskie,Poland "],
				[NSString stringWithFormat:@"%@",@"Acores,Portugal "],
				[NSString stringWithFormat:@"%@",@"Alentejo,Portugal "],
				[NSString stringWithFormat:@"%@",@"Algarve,Portugal "],
				[NSString stringWithFormat:@"%@",@"Centro,Portugal "],
				[NSString stringWithFormat:@"%@",@"Lisboa,Portugal "],
				[NSString stringWithFormat:@"%@",@"Madeira,Portugal "],
				[NSString stringWithFormat:@"%@",@"Norte,Portugal "],
				[NSString stringWithFormat:@"%@",@"Qatar,Qatar "],
				[NSString stringWithFormat:@"%@",@"Reunion,Reunion "],
				[NSString stringWithFormat:@"%@",@"Alba,Romania "],
				[NSString stringWithFormat:@"%@",@"Arad,Romania "],
				[NSString stringWithFormat:@"%@",@"Arges,Romania "],
				[NSString stringWithFormat:@"%@",@"Bacau,Romania "],
				[NSString stringWithFormat:@"%@",@"Bihor,Romania "],
				[NSString stringWithFormat:@"%@",@"Bistrita-Nasaud,Romania "],
				[NSString stringWithFormat:@"%@",@"Botosani,Romania "],
				[NSString stringWithFormat:@"%@",@"Braila,Romania "],
				[NSString stringWithFormat:@"%@",@"Brasov,Romania "],
				[NSString stringWithFormat:@"%@",@"Buzau,Romania "],
				[NSString stringWithFormat:@"%@",@"Calarasi,Romania "],
				[NSString stringWithFormat:@"%@",@"Caras-Severin,Romania "],
				[NSString stringWithFormat:@"%@",@"Cluj,Romania "],
				[NSString stringWithFormat:@"%@",@"Constanta,Romania "],
				[NSString stringWithFormat:@"%@",@"Covasna,Romania "],
				[NSString stringWithFormat:@"%@",@"Dambovita,Romania "],
				[NSString stringWithFormat:@"%@",@"Dolj,Romania "],
				[NSString stringWithFormat:@"%@",@"Galati,Romania "],
				[NSString stringWithFormat:@"%@",@"Giurgiu,Romania "],
				[NSString stringWithFormat:@"%@",@"Gorj,Romania "],
				[NSString stringWithFormat:@"%@",@"Harghita,Romania "],
				[NSString stringWithFormat:@"%@",@"Hunedoara,Romania "],
				[NSString stringWithFormat:@"%@",@"Ialomita,Romania "],
				[NSString stringWithFormat:@"%@",@"Iasi,Romania "],
				[NSString stringWithFormat:@"%@",@"Ilfov,Romania "],
				[NSString stringWithFormat:@"%@",@"Maramures,Romania "],
				[NSString stringWithFormat:@"%@",@"Mehedinti,Romania "],
				[NSString stringWithFormat:@"%@",@"Municipiul Bucuresti,Romania "],
				[NSString stringWithFormat:@"%@",@"Mures,Romania "],
				[NSString stringWithFormat:@"%@",@"Neamt,Romania "],
				[NSString stringWithFormat:@"%@",@"Olt,Romania "],
				[NSString stringWithFormat:@"%@",@"Prahova,Romania "],
				[NSString stringWithFormat:@"%@",@"Salaj,Romania "],
				[NSString stringWithFormat:@"%@",@"Satu Mare,Romania "],
				[NSString stringWithFormat:@"%@",@"Sibiu,Romania "],
				[NSString stringWithFormat:@"%@",@"Suceava,Romania "],
				[NSString stringWithFormat:@"%@",@"Teleorman,Romania "],
				[NSString stringWithFormat:@"%@",@"Timis,Romania "],
				[NSString stringWithFormat:@"%@",@"Tulcea,Romania "],
				[NSString stringWithFormat:@"%@",@"Unknown,Romania "],
				[NSString stringWithFormat:@"%@",@"Valcea,Romania "],
				[NSString stringWithFormat:@"%@",@"Vaslui,Romania "],
				[NSString stringWithFormat:@"%@",@"Vrancea,Romania "],
				[NSString stringWithFormat:@"%@",@"Aginskiy Buryatskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Altayskiy Kray,Russia "],
				[NSString stringWithFormat:@"%@",@"Amurskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Arkhangel'skaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Astrakhanskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Belgorodskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Bryanskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Chechenskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Chelyabinskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Chitinskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Chukotskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Chuvashskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Evenkiyskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Gorod Moskva,Russia "],
				[NSString stringWithFormat:@"%@",@"Gorod Sankt-Peterburg,Russia "],
				[NSString stringWithFormat:@"%@",@"Irkutskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Ivanovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Kabardino-Balkarskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Kaliningradskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Kaluzhskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Kamchatskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Karachayevo-Cherkesskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Kemerovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Khabarovskiy Kray,Russia "],
				[NSString stringWithFormat:@"%@",@"Khanty-Mansiyskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Kirovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Komi-Permyatskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Koryakskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Kostromskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Krasnodarskiy Kray,Russia "],
				[NSString stringWithFormat:@"%@",@"Krasnoyarskiy Kray,Russia "],
				[NSString stringWithFormat:@"%@",@"Kurganskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Kurskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Leningradskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Lipetskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Magadanskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Moskovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Murmanskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Nenetskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Nizhegorodskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Novgorodskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Novosibirskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Omskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Orenburgskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Orlovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Penzenskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Permskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Primorskiy Kray,Russia "],
				[NSString stringWithFormat:@"%@",@"Pskovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Adygeya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Altay,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Bashkortostan,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Buryatiya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Dagestan,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Kalmykiya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Kareliya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Khakasiya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Komi,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Mariy-El,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Mordoviya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Sakha,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Severnaya Osetiya-Alaniya,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Tatarstan,Russia "],
				[NSString stringWithFormat:@"%@",@"Respublika Tyva,Russia "],
				[NSString stringWithFormat:@"%@",@"Rostovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Ryazanskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Sakhalinskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Samarskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Saratovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Smolenskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Stavropol'skiy Kray,Russia "],
				[NSString stringWithFormat:@"%@",@"Sverdlovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Tambovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Taymyrskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Tomskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Tul'skaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Tverskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Tyumenskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Udmurtskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Ul'yanovskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Ust'-Ordynskiy Buryatskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Vladimirskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Volgogradskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Vologodskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Voronezhskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Yamalo-Nenetskiy,Russia "],
				[NSString stringWithFormat:@"%@",@"Yaroslavskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Yevreyskaya,Russia "],
				[NSString stringWithFormat:@"%@",@"Rwanda,Rwanda "],
				[NSString stringWithFormat:@"%@",@"Saint Helena,Saint Helena "],
				[NSString stringWithFormat:@"%@",@"Saint Kitts & Nevis,Saint Kitts and Nevis "],
				[NSString stringWithFormat:@"%@",@"Saint Lucia,Saint Lucia "],
				[NSString stringWithFormat:@"%@",@"Saint Pierre & Miquelon,Saint Pierre and Miquelon "],
				[NSString stringWithFormat:@"%@",@"Saint Vincent & the Grenadines,Saint Vincent and the Grenadines "],
				[NSString stringWithFormat:@"%@",@"Samoa,Samoa "],
				[NSString stringWithFormat:@"%@",@"San Marino,San Marino "],
				[NSString stringWithFormat:@"%@",@"Sao Tome & Principe,Sao Tome & Principe "],
				[NSString stringWithFormat:@"%@",@"Al Bahah,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Al Hudud ash Shamaliyah,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Al Madinah,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Al Mintaqah ash Sharqiyah,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Al Qasim,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Al-Jawf,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Ar Riyad,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Ha'il,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Jizan,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Makkah,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Tabuk,Saudi Arabia "],
				[NSString stringWithFormat:@"%@",@"Dakar,Senegal "],
				[NSString stringWithFormat:@"%@",@"Saint-Louis,Senegal "],
				[NSString stringWithFormat:@"%@",@"Thies,Senegal "],
				[NSString stringWithFormat:@"%@",@"Serbia & Montenegro,Serbia and Montenegro "],
				[NSString stringWithFormat:@"%@",@"Seychelles,Seychelles "],
				[NSString stringWithFormat:@"%@",@"Eastern Province,Sierra Leone "],
				[NSString stringWithFormat:@"%@",@"Northern Province,Sierra Leone "],
				[NSString stringWithFormat:@"%@",@"Southern Province,Sierra Leone "],
				[NSString stringWithFormat:@"%@",@"Western Area,Sierra Leone "],
				[NSString stringWithFormat:@"%@",@"Singapore,Singapore "],
				[NSString stringWithFormat:@"%@",@"Slovakia,Slovakia "],
				[NSString stringWithFormat:@"%@",@"Slovenia,Slovenia "],
				[NSString stringWithFormat:@"%@",@"Solomon Islands,Solomon Islands "],
				[NSString stringWithFormat:@"%@",@"Bakool,Somalia "],
				[NSString stringWithFormat:@"%@",@"Banaadir,Somalia "],
				[NSString stringWithFormat:@"%@",@"Bari,Somalia "],
				[NSString stringWithFormat:@"%@",@"Bay,Somalia "],
				[NSString stringWithFormat:@"%@",@"Gedo,Somalia "],
				[NSString stringWithFormat:@"%@",@"Jubbada Dhexe,Somalia "],
				[NSString stringWithFormat:@"%@",@"Jubbada Hoose,Somalia "],
				[NSString stringWithFormat:@"%@",@"Shabeellaha Hoose,Somalia "],
				[NSString stringWithFormat:@"%@",@"Eastern Cape,South Africa "],
				[NSString stringWithFormat:@"%@",@"Free State,South Africa "],
				[NSString stringWithFormat:@"%@",@"Gauteng,South Africa "],
				[NSString stringWithFormat:@"%@",@"KwaZulu-Natal,South Africa "],
				[NSString stringWithFormat:@"%@",@"Limpopo,South Africa "],
				[NSString stringWithFormat:@"%@",@"Mpumalanga,South Africa "],
				[NSString stringWithFormat:@"%@",@"North-West,South Africa "],
				[NSString stringWithFormat:@"%@",@"Northern Cape,South Africa "],
				[NSString stringWithFormat:@"%@",@"Unknown,South Africa "],
				[NSString stringWithFormat:@"%@",@"Western Cape,South Africa "],
				[NSString stringWithFormat:@"%@",@"South Georgia & South Sandwich Islands,South Georgia "],
				[NSString stringWithFormat:@"%@",@"Ch'ungch'ong-bukto,South Korea "],
				[NSString stringWithFormat:@"%@",@"Ch'ungch'ong-namdo,South Korea "],
				[NSString stringWithFormat:@"%@",@"Cheju-do,South Korea "],
				[NSString stringWithFormat:@"%@",@"Cholla-bukto,South Korea "],
				[NSString stringWithFormat:@"%@",@"Cholla-namdo,South Korea "],
				[NSString stringWithFormat:@"%@",@"Inch'on-gwangyoksi,South Korea "],
				[NSString stringWithFormat:@"%@",@"Kangwon-do,South Korea "],
				[NSString stringWithFormat:@"%@",@"Kwangju-gwangyoksi,South Korea "],
				[NSString stringWithFormat:@"%@",@"Kyonggi-do,South Korea "],
				[NSString stringWithFormat:@"%@",@"Kyongsang-bukto,South Korea "],
				[NSString stringWithFormat:@"%@",@"Kyongsang-namdo,South Korea "],
				[NSString stringWithFormat:@"%@",@"Pusan-gwangyoksi,South Korea "],
				[NSString stringWithFormat:@"%@",@"Soul-t'ukpyolsi,South Korea "],
				[NSString stringWithFormat:@"%@",@"Taegu-gwangyoksi,South Korea "],
				[NSString stringWithFormat:@"%@",@"Taejon-gwangyoksi,South Korea "],
				[NSString stringWithFormat:@"%@",@"Ulsan-gwangyoksi,South Korea "],
				[NSString stringWithFormat:@"%@",@"Andalucia,Spain "],
				[NSString stringWithFormat:@"%@",@"Aragon,Spain "],
				[NSString stringWithFormat:@"%@",@"Asturias,Spain "],
				[NSString stringWithFormat:@"%@",@"Baleares,Spain "],
				[NSString stringWithFormat:@"%@",@"Canarias,Spain "],
				[NSString stringWithFormat:@"%@",@"Cantabria,Spain "],
				[NSString stringWithFormat:@"%@",@"Castilla y Leon,Spain "],
				[NSString stringWithFormat:@"%@",@"Castilla-La Mancha,Spain "],
				[NSString stringWithFormat:@"%@",@"Cataluna,Spain "],
				[NSString stringWithFormat:@"%@",@"Ceuta y Melilla,Spain "],
				[NSString stringWithFormat:@"%@",@"Extremadura,Spain "],
				[NSString stringWithFormat:@"%@",@"Galicia,Spain "],
				[NSString stringWithFormat:@"%@",@"La Rioja,Spain "],
				[NSString stringWithFormat:@"%@",@"Madrid,Spain "],
				[NSString stringWithFormat:@"%@",@"Murcia,Spain "],
				[NSString stringWithFormat:@"%@",@"Navarra,Spain "],
				[NSString stringWithFormat:@"%@",@"Pais Vasco,Spain "],
				[NSString stringWithFormat:@"%@",@"Valencia,Spain "],
				[NSString stringWithFormat:@"%@",@"Sri Lanka,Sri Lanka "],
				[NSString stringWithFormat:@"%@",@"Sudan,Sudan "],
				[NSString stringWithFormat:@"%@",@"Suriname,Suriname "],
				[NSString stringWithFormat:@"%@",@"Svalbard,Svalbard "],
				[NSString stringWithFormat:@"%@",@"Swaziland,Swaziland "],
				[NSString stringWithFormat:@"%@",@"Blekinge lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Dalarnas lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Gavleborgs lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Gotlands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Hallands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Jamtlands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Jonkopings lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Kalmar lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Kronobergs lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Norrbottens lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Orebro lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Ostergotlands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Skane lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Sodermanlands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Stockholms lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Uppsala lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Varmlands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Vasterbottens lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Vasternorrlands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Vastmanlands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Vastra Gotalands lan,Sweden "],
				[NSString stringWithFormat:@"%@",@"Switzerland,Switzerland "],
				[NSString stringWithFormat:@"%@",@"Dar`a,Syria "],
				[NSString stringWithFormat:@"%@",@"Dayr az Zawr,Syria "],
				[NSString stringWithFormat:@"%@",@"Dimashq,Syria "],
				[NSString stringWithFormat:@"%@",@"Hamah,Syria "],
				[NSString stringWithFormat:@"%@",@"Hasakah,Syria "],
				[NSString stringWithFormat:@"%@",@"Hims,Syria "],
				[NSString stringWithFormat:@"%@",@"Ladhiqiyah,Syria "],
				[NSString stringWithFormat:@"%@",@"Unknown,Syria "],
				[NSString stringWithFormat:@"%@",@"Kao-hsiung,Taiwan "],
				[NSString stringWithFormat:@"%@",@"T'ai-pei,Taiwan "],
				[NSString stringWithFormat:@"%@",@"T'ai-wan,Taiwan "],
				[NSString stringWithFormat:@"%@",@"Khatlon,Tajikistan "],
				[NSString stringWithFormat:@"%@",@"Mukhtori Kuhistoni Badakhshon,Tajikistan "],
				[NSString stringWithFormat:@"%@",@"Sughd,Tajikistan "],
				[NSString stringWithFormat:@"%@",@"Unknown,Tajikistan "],
				[NSString stringWithFormat:@"%@",@"Kagera,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Kigoma,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Kilimanjaro,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Mwanza,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Rukwa,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Shinyanga,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Tabora,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Unknown,Tanzania "],
				[NSString stringWithFormat:@"%@",@"Bangkok Metropolis,Thailand "],
				[NSString stringWithFormat:@"%@",@"Central,Thailand "],
				[NSString stringWithFormat:@"%@",@"Northeastern,Thailand "],
				[NSString stringWithFormat:@"%@",@"Northern,Thailand "],
				[NSString stringWithFormat:@"%@",@"Southern,Thailand "],
				[NSString stringWithFormat:@"%@",@"Togo,Togo "],
				[NSString stringWithFormat:@"%@",@"Tokelau,Tokelau "],
				[NSString stringWithFormat:@"%@",@"Tonga,Tonga "],
				[NSString stringWithFormat:@"%@",@"Trinidad & Tobago,Trinidad and Tobago "],
				[NSString stringWithFormat:@"%@",@"Ariana,Tunisia "],
				[NSString stringWithFormat:@"%@",@"Mahdia,Tunisia "],
				[NSString stringWithFormat:@"%@",@"Sousse,Tunisia "],
				[NSString stringWithFormat:@"%@",@"Tunis,Tunisia "],
				[NSString stringWithFormat:@"%@",@"Unknown,Tunisia "],
				[NSString stringWithFormat:@"%@",@"Adana,Turkey "],
				[NSString stringWithFormat:@"%@",@"Ankara,Turkey "],
				[NSString stringWithFormat:@"%@",@"Antalya,Turkey "],
				[NSString stringWithFormat:@"%@",@"Aydin,Turkey "],
				[NSString stringWithFormat:@"%@",@"Bilecik,Turkey "],
				[NSString stringWithFormat:@"%@",@"Bursa,Turkey "],
				[NSString stringWithFormat:@"%@",@"Diyarbakir,Turkey "],
				[NSString stringWithFormat:@"%@",@"Erzurum,Turkey "],
				[NSString stringWithFormat:@"%@",@"Hakkari,Turkey "],
				[NSString stringWithFormat:@"%@",@"Hatay,Turkey "],
				[NSString stringWithFormat:@"%@",@"Icel,Turkey "],
				[NSString stringWithFormat:@"%@",@"Isparta,Turkey "],
				[NSString stringWithFormat:@"%@",@"Istanbul,Turkey "],
				[NSString stringWithFormat:@"%@",@"Izmir,Turkey "],
				[NSString stringWithFormat:@"%@",@"Karaman,Turkey "],
				[NSString stringWithFormat:@"%@",@"Kilis,Turkey "],
				[NSString stringWithFormat:@"%@",@"Kocaeli,Turkey "],
				[NSString stringWithFormat:@"%@",@"Konya,Turkey "],
				[NSString stringWithFormat:@"%@",@"Manisa,Turkey "],
				[NSString stringWithFormat:@"%@",@"Nigde,Turkey "],
				[NSString stringWithFormat:@"%@",@"Sirnak,Turkey "],
				[NSString stringWithFormat:@"%@",@"Sivas,Turkey "],
				[NSString stringWithFormat:@"%@",@"Yalova,Turkey "],
				[NSString stringWithFormat:@"%@",@"Ahal,Turkmenistan "],
				[NSString stringWithFormat:@"%@",@"Balkan,Turkmenistan "],
				[NSString stringWithFormat:@"%@",@"Dasoguz,Turkmenistan "],
				[NSString stringWithFormat:@"%@",@"Lebap,Turkmenistan "],
				[NSString stringWithFormat:@"%@",@"Mary,Turkmenistan "],
				[NSString stringWithFormat:@"%@",@"Turks & Caicos Islands,Turks and Caicos Islands "],
				[NSString stringWithFormat:@"%@",@"Tuvalu,Tuvalu "],
				[NSString stringWithFormat:@"%@",@"Uganda,Uganda "],
				[NSString stringWithFormat:@"%@",@"Cherkas'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Chernihivs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Chernivets'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Dnipropetrovs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Donets'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Ivano-Frankivs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Kharkivs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Khersons'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Khmel'nyts'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Kirovohrads'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Kyrm,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Kyyivs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"L'vivs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Luhans'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Misto Kyyiv,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Misto Sevastopol',Ukraine "],
				[NSString stringWithFormat:@"%@",@"Mykolayivs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Odes'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Poltavs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Rivnens'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Sums'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Ternopil's'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Vinnyts'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Volyns'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Zakarpats'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Zaporiz'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"Zhytomyrs'ka,Ukraine "],
				[NSString stringWithFormat:@"%@",@"United Arab Emirates,United Arab Emirates "],
				[NSString stringWithFormat:@"%@",@"England,United Kingdom "],
				[NSString stringWithFormat:@"%@",@"Northern Ireland,United Kingdom "],
				[NSString stringWithFormat:@"%@",@"Scotland,United Kingdom "],
				[NSString stringWithFormat:@"%@",@"Wales,United Kingdom "],
				[NSString stringWithFormat:@"%@",@"Alabama,United States "],
				[NSString stringWithFormat:@"%@",@"Alaska,United States "],
				[NSString stringWithFormat:@"%@",@"American Samoa,United States "],
				[NSString stringWithFormat:@"%@",@"Arizona,United States "],
				[NSString stringWithFormat:@"%@",@"Arkansas,United States "],
				[NSString stringWithFormat:@"%@",@"California,United States "],
				[NSString stringWithFormat:@"%@",@"Colorado,United States "],
				[NSString stringWithFormat:@"%@",@"Connecticut,United States "],
				[NSString stringWithFormat:@"%@",@"Delaware,United States "],
				[NSString stringWithFormat:@"%@",@"District of Columbia,United States "],
				[NSString stringWithFormat:@"%@",@"Florida,United States "],
				[NSString stringWithFormat:@"%@",@"Georgia,United States "],
				[NSString stringWithFormat:@"%@",@"Guam,United States "],
				[NSString stringWithFormat:@"%@",@"Hawaii,United States "],
				[NSString stringWithFormat:@"%@",@"Idaho,United States "],
				[NSString stringWithFormat:@"%@",@"Illinois,United States "],
				[NSString stringWithFormat:@"%@",@"Indiana,United States "],
				[NSString stringWithFormat:@"%@",@"Iowa,United States "],
				[NSString stringWithFormat:@"%@",@"Kansas,United States "],
				[NSString stringWithFormat:@"%@",@"Kentucky,United States "],
				[NSString stringWithFormat:@"%@",@"Louisiana,United States "],
				[NSString stringWithFormat:@"%@",@"Maine,United States "],
				[NSString stringWithFormat:@"%@",@"Maryland,United States "],
				[NSString stringWithFormat:@"%@",@"Massachusetts,United States "],
				[NSString stringWithFormat:@"%@",@"Michigan,United States "],
				[NSString stringWithFormat:@"%@",@"Minnesota,United States "],
				[NSString stringWithFormat:@"%@",@"Mississippi,United States "],
				[NSString stringWithFormat:@"%@",@"Missouri,United States "],
				[NSString stringWithFormat:@"%@",@"Montana,United States "],
				[NSString stringWithFormat:@"%@",@"Nebraska,United States "],
				[NSString stringWithFormat:@"%@",@"Nevada,United States "],
				[NSString stringWithFormat:@"%@",@"New Hampshire,United States "],
				[NSString stringWithFormat:@"%@",@"New Jersey,United States "],
				[NSString stringWithFormat:@"%@",@"New Mexico,United States "],
				[NSString stringWithFormat:@"%@",@"New York,United States "],
				[NSString stringWithFormat:@"%@",@"North Carolina,United States "],
				[NSString stringWithFormat:@"%@",@"North Dakota,United States "],
				[NSString stringWithFormat:@"%@",@"Northern Mariana Islands,United States "],
				[NSString stringWithFormat:@"%@",@"Ohio,United States "],
				[NSString stringWithFormat:@"%@",@"Oklahoma,United States "],
				[NSString stringWithFormat:@"%@",@"Oregon,United States "],
				[NSString stringWithFormat:@"%@",@"Pennsylvania,United States "],
				[NSString stringWithFormat:@"%@",@"Puerto Rico,United States "],
				[NSString stringWithFormat:@"%@",@"Rhode Island,United States "],
				[NSString stringWithFormat:@"%@",@"South Carolina,United States "],
				[NSString stringWithFormat:@"%@",@"South Dakota,United States "],
				[NSString stringWithFormat:@"%@",@"Tennessee,United States "],
				[NSString stringWithFormat:@"%@",@"Texas,United States "],
				[NSString stringWithFormat:@"%@",@"Utah,United States "],
				[NSString stringWithFormat:@"%@",@"Vermont,United States "],
				[NSString stringWithFormat:@"%@",@"Virgin Islands,United States "],
				[NSString stringWithFormat:@"%@",@"Virginia,United States "],
				[NSString stringWithFormat:@"%@",@"Washington,United States "],
				[NSString stringWithFormat:@"%@",@"West Virginia,United States "],
				[NSString stringWithFormat:@"%@",@"Wisconsin,United States "],
				[NSString stringWithFormat:@"%@",@"Wyoming,United States "],
				[NSString stringWithFormat:@"%@",@"Artigas,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Canelones,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Cerro Largo,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Colonia,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Durazno,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Florida,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Lavalleja,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Maldonado,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Montevideo,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Paysandu,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Rio Negro,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Rivera,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Rocha,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Salto,Uruguay "],
				[NSString stringWithFormat:@"%@",@"San Jose,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Soriano,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Tacuarembo,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Treinta y Tres,Uruguay "],
				[NSString stringWithFormat:@"%@",@"Andijon,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Buxoro,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Jizzax,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Namangan,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Navoiy,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Qashqadaryo,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Qoraqalpog`iston,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Samarqand,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Sirdaryo,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Surxondaryo,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Toshkent,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Toshkent Shahri,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Unknown,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Xorazm,Uzbekistan "],
				[NSString stringWithFormat:@"%@",@"Vanuatu,Vanuatu "],
				[NSString stringWithFormat:@"%@",@"Vatican City,Vatican City "],
				[NSString stringWithFormat:@"%@",@"Amazonas,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Anzoategui,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Apure,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Aragua,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Barinas,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Bolivar,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Carabobo,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Falcon,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Guarico,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Lara,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Merida,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Miranda,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Monagas,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Nueva Esparta,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Sucre,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Tachira,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Trujillo,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Vargas,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Yaracuy,Venezuela "],
				[NSString stringWithFormat:@"%@",@"Zulia,Venezuela "],
				[NSString stringWithFormat:@"%@",@"An Giang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ba Ria-Vung Tau,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Bac Giang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Bac Kan,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Bac Lieu,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Bac Ninh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ben Tre,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Binh Dinh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Binh Duong,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Binh Phuoc,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Binh Thuan,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ca Mau,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Can Tho,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Cao Bang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Da Nang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Dac Lak,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Dong Nai,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Dong Thap,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Gia Lai,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ha Giang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ha Nam,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ha Tay,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ha Tinh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Hai Duong,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Hoa Binh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Hung Yen,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Khanh Hoa,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Kien Giang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Kon Tum,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Lai Chau,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Lam Dong,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Lang Son,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Lao Cai,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Long An,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Nam Dinh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Nghe An,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ninh Binh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Ninh Thuan,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Phu Tho,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Phu Yen,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Quang Binh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Quang Nam,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Quang Ngai,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Quang Ninh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Quang Tri,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Soc Trang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Son La,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Tay Ninh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Thai Binh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Thai Nguyen,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Thanh Hoa,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Thanh Pho Hai Phong,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Thanh Pho Ho Chi Minh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Thu Do Ha Noi,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Thua Thien-Hue,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Tien Giang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Tra Vinh,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Tuyen Quang,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Vinh Long,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Vinh Phuc,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Yen Bai,Vietnam "],
				[NSString stringWithFormat:@"%@",@"Wallis & Futuna,Wallis and Futuna "],
				[NSString stringWithFormat:@"%@",@"Yemen,Yemen "],
				[NSString stringWithFormat:@"%@",@"Central,Zambia "],
				[NSString stringWithFormat:@"%@",@"Eastern,Zambia "],
				[NSString stringWithFormat:@"%@",@"Lusaka,Zambia "],
				[NSString stringWithFormat:@"%@",@"Southern,Zambia "],
				[NSString stringWithFormat:@"%@",@"Unknown,Zambia "],
				[NSString stringWithFormat:@"%@",@"Western,Zambia "],
				[NSString stringWithFormat:@"%@",@"Harare,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Manicaland,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Mashonaland East,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Mashonaland West,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Masvingo,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Matabeleland North,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Matabeleland South,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Midlands,Zimbabwe "],
				[NSString stringWithFormat:@"%@",@"Unknown,Zimbabwe"],
				nil];
	
	
	
	
	
	
	//self.window.rootViewController = self.tabBarController;
    
    LoginView * lv = [[LoginView alloc]init];
    
    UINavigationController * lvc = [[UINavigationController alloc]initWithRootViewController:lv];
    
    [self.window setRootViewController:lvc];
    [lvc release];
    [lv release];
    
	[self.window makeKeyAndVisible];
	
	return YES;
}

-(void) doLogout{
    
    //    self.user_id = 0;
    LoginView * lv = [[LoginView alloc] init];
    UINavigationController * lvc = [[UINavigationController alloc]initWithRootViewController:lv];
    [self.window setRootViewController:lvc];
    [lvc release];
    [lv release];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	
	
	
	
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
	 */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
	 Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
	 */
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
   // [self rescheduleNotifications];
    
    // Handle launching from a notification
    
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
	
	sqlite3_close(database);
	
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
	
	[indicationsConditions release];
    indicationsConditions = nil;
    [indicationsSymptoms release];
    indicationsSymptoms = nil;
    [indicationsTestResults release];
    indicationsTestResults = nil;
	
	[treatmentMedication release];
    treatmentMedication = nil;
    [treatmentTherapies release];
    treatmentTherapies = nil;
    [treatmentFood release];
    treatmentFood = nil;
	
	[treatmentTypes release];
	
	
    [providersPhysicians release];
    providersPhysicians = nil;
    [providersTherapists release];
    providersTherapists = nil;
    [providersOthers release];
    providersOthers = nil;
	
	[cityList release];
	
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

