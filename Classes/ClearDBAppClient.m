/** ***************************************************************************
 * The Official ClearDB Objective-C API App Client.
 * ----------------------------------------------------------------------------
 * Copyright (c) 2010 SuccessBricks, Inc. All rights reserved.
 * 
 * Use of this software and source code is subject to the ClearDB Terms of
 * Service / Acceptable Use Policy, available at
 * http://www.cleardb.com/legal/terms_of_service.html as well as the
 * ClearDB Website Terms of Use, at
 * http://www.cleardb.com/legal/terms_of_use.html.
 *
 * THIS SOFTWARE, INCLUDING THE INFORMATION THEREIN IS PROVIDED "AS IS".
 * SUCCESSBRICKS, INC. DISCLAIMS ALL EXPRESS OR IMPLIED CONDITIONS,
 * REPRESENTATIONS, AND WARRANTIES OF ANY KIND, INCLUDING ANY IMPLIED
 * WARRANTY OR CONDITION OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS
 * FOR A PARTICULAR PURPOSE, OR NINFRINGEMENT.
 * ----------------------------------------------------------------------------
 * @see http://www.cleardb.com/v1/doc/appQuery
 * @see http://www.cleardb.com/v1/doc/sendAppTransaction
 * @version 1.0
 * @author Cashton Coleman
 * ****************************************************************************/
#import "ClearDBAppClient.h"

@implementation ClearDBAppClient

@synthesize payload, rows, API_KEY, APP_ID;

- (void)initializeClearDB {
	API_URL = [[NSURL URLWithString:@"https://www.cleardb.com/v1/api.php"] retain];
	statements = [[NSMutableArray alloc] init];
}

- (void)notifyCDBReadyEvent {
    NSLog(@"Posting ready event");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"cdbReadyEvent" object:self.rows];
}

- (void)notifyCDBConnectFailedEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"cdbConnectFailedEvent" object:nil];
}

- (void)notifyCDBQueryFailedEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"cdbQueryFailedEvent" object:nil];
}

- (void)notifyCDBTransactionFailedEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"cdbTransactionFailedEvent" object:nil];
}

- (void)callApi:(NSString *)action:(NSString *)query {
	
	int key_length = [API_KEY length];
	int id_length = [APP_ID length];
	
	if (key_length == 0 || id_length == 0) {
		NSLog(@"*** ClearDB Call Failed. Please make sure that your API_KEY and APP_ID values are set before making calls to the API.");
		[self notifyCDBConnectFailedEvent];
		return;
	}
	
	payload = [[NSMutableData data] retain];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:API_URL];
	
	[request setHTTPMethod:@"POST"];
	
	NSString *postData = [[[NSString stringWithFormat:@"api_key=%@&app_id=%@&action=%@&%@", 
						  API_KEY, APP_ID, action, query]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]stringByReplacingOccurrencesOfString:@"+0000" withString:@"*0000"];
	
	NSLog(@"POST DATA: '%@'", postData);
	
	[request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
	
	[request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[payload setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[payload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"*** ClearDB Connection Failed. Please check your network connection and try again.");
	[self notifyCDBConnectFailedEvent];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *rawJSON = [[[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"*0000" withString:@"+0000"];
	
	//NSLog(@"JSON RESPONSE: '%@'", rawJSON);
	
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	
	NSDictionary *response = [parser objectWithString:rawJSON error:nil];
		
	if ([[response objectForKey:@"result"] isEqual:@"failure"]) {
		
		if (inTransaction) {
			[self notifyCDBTransactionFailedEvent];
		} else {
			[self notifyCDBQueryFailedEvent];
		}
		
		NSLog(@"*** ClearDB Response Failure: %@ ***", [response objectForKey:@"reason"]);
		return;
	}
	
	rows = [response objectForKey:@"response"];
	
	[self notifyCDBReadyEvent];
}

- (void)query:(NSString *)sql {
	if (inTransaction) {
		[statements addObject:sql];
		return;
	}
	
	sql = [NSString stringWithFormat:@"query=%@", sql];
	[self callApi:@"appQuery":sql];
}

- (void)sendTransaction {
	if (!inTransaction) {
		NSLog(@"*** ClearDB Transaction Error - no transaction currently exists to send!");
		[self notifyCDBTransactionFailedEvent];
		return;
	}
	
	NSString *statement_string = [[NSString alloc] initWithString:[statements componentsJoinedByString:@"&statements[]="]];
	statement_string = [NSString stringWithFormat:@"statements[]=%@", statement_string];
	
	[self callApi:@"sendAppTransaction":statement_string];
	
	//[statements init];
    [statements removeAllObjects];
	inTransaction = FALSE;
}

- (void)startTransaction {
	if (inTransaction) {
		NSLog(@"*** ClearDB Transaction Error - a transaction already exists.");
		[self notifyCDBTransactionFailedEvent];
		return;
	}
	
	inTransaction = TRUE;
	[statements init];
}

- (void)rollbackTransaction {
	if (!inTransaction) {
		NSLog(@"*** ClearDB Transaction Error - no transaction currently exists to roll back.");
		[self notifyCDBTransactionFailedEvent];
		return;
	}
	inTransaction = FALSE;
	[statements init];
}

- (void)callProcedure:(NSString *)name:(NSMutableArray *)params {
	
	NSString *statement_string = [[NSString alloc] initWithString:[params componentsJoinedByString:@"&params[]="]];
	statement_string = [NSString stringWithFormat:@"name=%@&params[]=%@", name, statement_string];
	
	[self callApi:@"runAppStoredProcedure":statement_string];
}

@end
