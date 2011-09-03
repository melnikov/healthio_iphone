//
//  ComplianceChart.m
//  HealthIO
//
//  Created by Alexei Melnikov on 8/9/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import "ComplianceChart.h"
#import <QuartzCore/QuartzCore.h>


@implementation ComplianceChart

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Compliance Chart";
	self.view.backgroundColor = [UIColor colorWithRed:0.761 green:0.847 blue:0.949 alpha:1.0];
	
	
}

- (void)drawRect:(CGRect)rect {

	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(contextRef, 0, 0, 255, 0.1);
	CGContextSetRGBStrokeColor(contextRef, 0, 0, 255, 0.5);
	
	// Draw a circle (filled)
	CGContextFillEllipseInRect(contextRef, CGRectMake(100, 100, 25, 25));
	
	// Draw a circle (border only)
	CGContextStrokeEllipseInRect(contextRef, CGRectMake(100, 100, 25, 25));
	
	// Get the graphics context and clear it
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextClearRect(ctx, rect);
	
	// Draw a green solid circle
	CGContextSetRGBFillColor(ctx, 0, 255, 0, 1);
	CGContextFillEllipseInRect(ctx, CGRectMake(100, 100, 25, 25));
	
	// Draw a yellow hollow rectangle
	CGContextSetRGBStrokeColor(ctx, 255, 255, 0, 1);
	CGContextStrokeRect(ctx, CGRectMake(195, 195, 60, 60));
	
	// Draw a purple triangle with using lines
	CGContextSetRGBStrokeColor(ctx, 255, 0, 255, 1);
	CGPoint points[6] = { CGPointMake(100, 200), CGPointMake(150, 250),
		CGPointMake(150, 250), CGPointMake(50, 250),
		CGPointMake(50, 250), CGPointMake(100, 200) };
	CGContextStrokeLineSegments(ctx, points, 6);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
