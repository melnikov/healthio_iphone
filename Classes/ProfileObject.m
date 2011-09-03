//
//  ProfileObject.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "ProfileObject.h"


@implementation ProfileObject
@synthesize mobileName;
@synthesize email;
@synthesize city;
@synthesize gender;
@synthesize age;
@synthesize height;
@synthesize weight;
@synthesize drinkStatus;
@synthesize tobaccoStatus;
@synthesize ring;
@synthesize vibrate;
@synthesize alert;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithMobileName:(NSString*)aMobileName email:(NSString*)anEmail city:(NSString*)aCity gender:(int)aGender age:(int)aAge height:(int)anHeight weight:(int)aWeight drinkStatus:(int)aDrinkStatus tobaccoStatus:(int)aTobaccoStatus ring:(_Bool)rlag vibrate:(_Bool)vlag alert:(_Bool)alag 
{
    self = [super init];
    if (self) {
        mobileName = [aMobileName retain];
        email = [anEmail retain];
        city = [aCity retain];
        gender = aGender;
        age = aAge;
        height = anHeight;
        weight = aWeight;
        drinkStatus = aDrinkStatus;
        tobaccoStatus = aTobaccoStatus;
        ring = rlag;
        vibrate = vlag;
        alert = alag;
    }
    return self;
}


@end
