//
//  TreatmentObject.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndicationsObject.h"

@interface TreatmentObject : IndicationsObject {

	int treatmentType;
	NSString * strengthValue;
	int medicalSystem;
}

@property (nonatomic) int treatmentType;
@property (nonatomic,retain) NSString * strengthValue;
@property (nonatomic) int medicalSystem;


+ (id)objectWithName:(NSString*)aName description:(NSString*)aDescription startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate repeatType:(int)aRepeatType 
	   treatmentType:(int)aTreatmentType strength:(NSString *) aStrength medicalSystem:(int)aMedicalSystem;


@end
