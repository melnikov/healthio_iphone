//
//  QuestionObject.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "QuestionObject.h"


@implementation QuestionObject
@synthesize variants;
@synthesize question;
@synthesize answer;
@synthesize questionDate;
@synthesize responseDate;

//=========================================================== 
// - (id)initWith:
//
//=========================================================== 
- (id)initWithVariants:(NSArray*)aVariants question:(NSString*)aQuestion answer:(int)anAnswer questionDate:(NSDate*)aQuestionDate responseDate:(NSDate*)aResponseDate 
{
    self = [super init];
    if (self) {
        variants = [aVariants retain];
        question = [aQuestion retain];
        answer = anAnswer;
        questionDate = [aQuestionDate retain];
        responseDate = [aResponseDate retain];
    }
    return self;
}


//=========================================================== 
// + (id)objectWith:
//
//=========================================================== 
+ (id)objectWithVariants:(NSArray*)aVariants question:(NSString*)aQuestion answer:(int)anAnswer questionDate:(NSDate*)aQuestionDate responseDate:(NSDate*)aResponseDate  
{
    id result = [[[self class] alloc] initWithVariants:aVariants question:aQuestion answer:anAnswer questionDate:aQuestionDate responseDate:aResponseDate];
	
    return [result autorelease];
}

@end
