//
//  RegistrationView.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/25/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegistrationView : UIViewController {
    IBOutlet UITextField * lb_login;
    IBOutlet UITextField * lb_password;
    IBOutlet UITextField * lb_password2;
    int request_tag;
}

@property (nonatomic, retain) IBOutlet UITextField *lb_login;
@property (nonatomic, retain) IBOutlet UITextField *lb_password;
@property (nonatomic, retain) IBOutlet UITextField *lb_password2;
@property (nonatomic) int request_tag;

@end
