//
//  ProviderObject.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/2/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProviderObject : NSObject {

	NSString * name;
	int section;
	int specialty;
	NSString * affiliation;
	NSString * cityName;
	int city;
	NSString * phone;
	NSString * fax;
	NSString * email;
	float rating;
	int ID;
}

@property (readwrite) int ID;
@property (readwrite) int section;

@property (nonatomic, retain) NSString *name;
@property (nonatomic) int specialty;
@property (nonatomic, retain) NSString *affiliation;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic) int city;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *fax;
@property (nonatomic, retain) NSString *email;
@property (nonatomic) float rating;
- (id)initWithName:(NSString*)aName Id:(int)aId specialty:(int)aSpecialty affiliation:(NSString*)anAffiliation cityName:(NSString*)aCityName city:(int)aCity phone:(NSString*)aPhone fax:(NSString*)aFax email:(NSString*)anEmail rating:(float)aRating;
+ (id)objectWithName:(NSString*)aName specialty:(int)aSpecialty affiliation:(NSString*)anAffiliation cityName:(NSString*)aCityName city:(int)aCity phone:(NSString*)aPhone fax:(NSString*)aFax email:(NSString*)anEmail rating:(float)aRating;

@end
