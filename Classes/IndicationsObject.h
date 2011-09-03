//
//  TreatmentObject.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IndicationsObject : NSObject {

	NSString * name;
	NSString * description;
	NSDate * startDate;
	NSDate * endDate;
	NSDate * lastUpdateDate;
	int repeatType;
	NSMutableArray * repeatTimes;

	int severity;
	int ID;
	int section;
	
	
}
@property (readwrite) int ID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *lastUpdateDate;
@property (nonatomic, retain) NSMutableArray * repeatTimes;
@property (nonatomic) int repeatType;
@property (nonatomic) int severity;
@property (readwrite) int section;

- (id)initWithName:(NSString*)aName Id:(int)aId description:(NSString*)aDescription startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate repeatType:(int)aRepeatType;
+ (id)objectWithName:(NSString*)aName description:(NSString*)aDescription startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate repeatType:(int)aRepeatType;
@end
