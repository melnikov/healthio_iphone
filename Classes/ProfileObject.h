//
//  ProfileObject.h
//  HealthIO
//
//  Created by Alexei Melnikov on 7/27/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProfileObject : NSObject {
	NSString * mobileName;
	NSString * email;
	NSString * city;
	int gender;
	int age;
	int height;
	int weight;
	int drinkStatus;
	int tobaccoStatus;
	bool ring;
	bool vibrate;
	bool alert;
	
}

@property (nonatomic, retain) NSString *mobileName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *city;
@property (nonatomic) int gender;
@property (nonatomic) int age;
@property (nonatomic) int height;
@property (nonatomic) int weight;
@property (nonatomic) int drinkStatus;
@property (nonatomic) int tobaccoStatus;
@property (nonatomic) bool ring;
@property (nonatomic) bool vibrate;
@property (nonatomic) bool alert;

- (id)initWithMobileName:(NSString*)aMobileName email:(NSString*)anEmail city:(NSString*)aCity gender:(int)aGender age:(int)aAge  height:(int)anHeight weight:(int)aWeight drinkStatus:(int)aDrinkStatus tobaccoStatus:(int)aTobaccoStatus ring:(bool)rlag vibrate:(bool)vlag alert:(bool)alag;

@end
