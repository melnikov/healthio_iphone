//
//  QuestionObject.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QuestionObject : NSObject {

	NSArray * variants;
	NSString * question;
	int answer;
	NSDate * questionDate;
	NSDate * responseDate;
	
}

@property (nonatomic, retain) NSArray *variants;
@property (nonatomic, retain) NSString *question;
@property (nonatomic) int answer;
@property (nonatomic, retain) NSDate *questionDate;
@property (nonatomic, retain) NSDate *responseDate;
- (id)initWithVariants:(NSArray*)aVariants question:(NSString*)aQuestion answer:(int)anAnswer questionDate:(NSDate*)aQuestionDate responseDate:(NSDate*)aResponseDate;
+ (id)objectWithVariants:(NSArray*)aVariants question:(NSString*)aQuestion answer:(int)anAnswer questionDate:(NSDate*)aQuestionDate responseDate:(NSDate*)aResponseDate;

@end
