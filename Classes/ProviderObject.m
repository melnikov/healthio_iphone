//
//  ProviderObject.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "ProviderObject.h"


@implementation ProviderObject
@synthesize name;
@synthesize specialty;
@synthesize affiliation;
@synthesize cityName;
@synthesize city;
@synthesize phone;
@synthesize fax;
@synthesize email;
@synthesize rating;
@synthesize ID;
@synthesize section;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithName:(NSString*)aName Id:(int)aId specialty:(int)aSpecialty affiliation:(NSString*)anAffiliation cityName:(NSString*)aCityName city:(int)aCity phone:(NSString*)aPhone fax:(NSString*)aFax email:(NSString*)anEmail rating:(float)aRating 
{
    self = [super init];
    if (self) {
        name = [aName retain];
        specialty = aSpecialty;
        affiliation = [anAffiliation retain];
        cityName = [aCityName retain];
        city = aCity;
        phone = [aPhone retain];
        fax = [aFax retain];
        email = [anEmail retain];
        rating = aRating;
		ID = aId;
    }
    return self;
}


//=========================================================== 
// + (id)objectWith:
//
//=========================================================== 
+ (id)objectWithName:(NSString*)aName specialty:(int)aSpecialty affiliation:(NSString*)anAffiliation cityName:(NSString*)aCityName city:(int)aCity phone:(NSString*)aPhone fax:(NSString*)aFax email:(NSString*)anEmail rating:(float)aRating  
{
    id result = [[[self class] alloc] initWithName:aName Id:-1 specialty:aSpecialty affiliation:anAffiliation cityName:aCityName city:aCity phone:aPhone fax:aFax email:anEmail rating:aRating];
	
    return [result autorelease];
}

@end
