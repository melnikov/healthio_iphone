//
//  TreatmentObject.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "IndicationsObject.h"


@implementation IndicationsObject


@synthesize name;
@synthesize description;
@synthesize startDate;
@synthesize endDate;
@synthesize lastUpdateDate;
@synthesize repeatType;
@synthesize severity;
@synthesize ID;
@synthesize section;
@synthesize repeatTimes;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithName:(NSString*)aName Id:(int)aId description:(NSString*)aDescription startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate repeatType:(int)aRepeatType 
{
    self = [super init];
    if (self) {
        name = [aName retain];
        description = [aDescription retain];
        startDate = [aStartDate retain];
		//repeatTime = [aStartDate retain];
        if (anEndDate)
        {
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSDateComponents * tmp = [cal components:NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit fromDate:anEndDate];
        [tmp setHour:23];
        [tmp setMinute:59];
        [tmp setSecond:59];
        
        endDate = [[cal dateFromComponents:tmp]  retain];
        }
        else
            endDate = nil;
        repeatType = aRepeatType;
		lastUpdateDate = nil;
		severity = -1;
		ID = aId;
        repeatTimes = [[NSMutableArray arrayWithCapacity:0]retain];
    }
       return self;
}


+ (id)objectWithName:(NSString*)aName description:(NSString*)aDescription startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate repeatType:(int)aRepeatType  
{
    id result = [[[self class] alloc] initWithName:aName Id:-1 description:aDescription startDate:aStartDate endDate:anEndDate repeatType:aRepeatType];
	return [result autorelease];
}

@end
