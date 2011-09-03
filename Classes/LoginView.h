//
//  LoginView.h
//  HealthIO
//
//  Created by Alexei Melnikov on 8/23/11.
//  Copyright 2011 Stex Group LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClearDBAppClient.h"

@interface LoginView : UIViewController {
    ClearDBAppClient * client;
    IBOutlet UITextField * login;
    IBOutlet UITextField * password;
    
    IBOutlet UIButton * bt_login;
    IBOutlet UIButton * bt_pass;
        IBOutlet UIButton * bt_reset;
    IBOutlet UIActivityIndicatorView * spinner;
    int request_tag;
    
    NSString * forced_login;
    NSString * forced_password;
    
    int forcedUid;
}

//@property (nonatomic) ClearDBAppClient * client;

@property (nonatomic,retain) IBOutlet UITextField * login;
@property (nonatomic,retain) IBOutlet UITextField * password;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * spinner;

@property(nonatomic,retain) IBOutlet UIButton * bt_login; 
@property(nonatomic, retain) IBOutlet UIButton * bt_pass;
@property(nonatomic, retain) IBOutlet UIButton * bt_reset;

@property (nonatomic,retain) NSString * forced_login;
@property (nonatomic,retain) NSString * forced_password;

@property (nonatomic) int request_tag;

@property (nonatomic) int forcedUid;

- (id)initWithForced_login:(NSString*)aForced_login forced_password:(NSString*)aForced_password;
- (id)initWithForcedUid:(int)aUid;
-(IBAction) didClickLoginButton:(id)sender;
-(IBAction) didClickPasswordRetrievalButton:(id)sender;
-(IBAction) didClickRegisterButton:(id)sender;

@end
