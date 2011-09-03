//
//  TreatmentObject.m
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "TreatmentObject.h"


@implementation TreatmentObject

@synthesize treatmentType;
@synthesize strengthValue;
@synthesize medicalSystem;

+ (id)objectWithName:(NSString*)aName description:(NSString*)aDescription startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate repeatType:(int)aRepeatType 
	   treatmentType:(int)aTreatmentType strength:(NSString *) aStrength medicalSystem:(int)aMedicalSystem{

	TreatmentObject* result = [[TreatmentObject alloc] initWithName:aName Id:-1 description:aDescription startDate:aStartDate endDate:anEndDate repeatType:aRepeatType];
	
	[result setTreatmentType:aTreatmentType];
	[result setStrengthValue:[NSString stringWithFormat:@"%@",aStrength]];
	[result setMedicalSystem:aMedicalSystem];
	
    return [result autorelease];
	
}

@end
