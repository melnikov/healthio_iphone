//
//  Question.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Question : UIViewController <UITableViewDelegate,UITableViewDataSource> {

	int index;
	int tmpAnswer;
	IBOutlet UITableView * table;
	IBOutlet UILabel * lbQuestion;
}

@property (nonatomic) int index;
@property (nonatomic) int tmpAnswer;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UILabel *lbQuestion;
- (id)initWithIndex:(int)anIndex;


@end
