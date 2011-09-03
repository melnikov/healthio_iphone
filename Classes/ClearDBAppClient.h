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
 * FOR A PARTICULAR PURPOSE, OR NONINFRINGEMENT.
 * ----------------------------------------------------------------------------
 * @see http://www.cleardb.com/v1/doc/appQuery
 * @see http://www.cleardb.com/v1/doc/sendAppTransaction
 * @version 1.0
 * @author Cashton Coleman
 * ****************************************************************************/

#import <Foundation/Foundation.h>
#import "JSON.h"

/** ***************************************************************************
 How to use the API App Client Library
 ------------------------------------------------------------------------------
 
 Installation
 ------------
 To begin, place this header file in your project, in the Classes folder. This 
 will make your project aware of the ClearDB App Client.
 
 Next, drag the library file itself (libClearDB_ObjC_Client.a) into your 
 Frameworks folder. You should probably also check the option to copy the file 
 into your project rather than leaving it wherever it is now.
 
 
 Getting Started
 ---------------
 Start by importing this file into the header file of the class(es) that you 
 will be using the ClearDB client in. You may have a master header file that 
 you add all of your external headers into - this would be a great place to 
 put the following import statement:
 
	#import "ClearDBAppClient.h"
 
 Next, add the following:

	ClearDBAppClient *client;
 
 ... to the @interface definition. This will make the ClearDBAppClient instance 
 available to the class as a whole.
 
 Now you can start working with the client initialization and operations.
 
 
 Initializing & Setting Callback Event Handlers
 ----------------------------------------------
 To initialize the client, do this:
 
	client = [ClearDBAppClient alloc];
	[client initializeClearDB];
 
 This is typically done in one line, but there are a few special functions in 
 the ClearDB App Client that prevent doing so from working correctly. We also need to 
 set the API_KEY and APP_ID values so that your client can identify you to ClearDB. 
 
	client.APP_ID = @"58d7fffb22a5639da4affaac581125a6"; // replace with your App ID.
	client.API_KEY = @"0c7be19d4ec94044a4fcb830463e89a6d276f004"; // replace with your API_KEY.
 
 If you have not yet created your App ID and API Key, you'll need to do that 
 before continuing. See http://www.cleardb.com/api.html (Login Required) to 
 set up your App, API Key, and Access Rules to define the security model for 
 the API Key you will be using here.
 
 Now that the client has been initialized, let's have a look at the four 
 primary events that the ClearDB App Client triggers during operations:
 
  - cdbReadyEvent: the event that is raised when a query completes.
 
  - cdbConnectFailedEvent: the event that is raised when a connection to the 
		ClearDB API cannot be completed due to invalid API or App keys, or if 
		no connection can be established due to lack of network availability.
 
  - cdbQueryFailedEvent: the event that is raised if the query fails due to 
		a problem with API or App key validation, or if the query contains a 
		SQL syntax error or illegal statement. Additionaly, if the API/App Key 
		validation succeeds but the query contains a statement that is restricted 
		due to Access Rules, this event will be raised to reflect that.
 
  - cdbTransactionFailedEvent: the event that is raised if the query fails due 
		to a SQL error, data integrity error, or an illegal statement. As with 
		standard query errors, this will also be triggered if the API/App Key 
		validation succeeds but the query contains a statement that is restricted 
		due to Access Rules.
 
 To register observers for these events, you can use the following statements:
 
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(clearDBDidFinishQuery:) 
		name:@"cdbReadyEvent" 
		object:nil];
 
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(clearDBDidFailWithError:) 
		name:@"cdbConnectFailedEvent" 
		object:nil];
 
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(clearDBQueryDidFailWithError:) 
		name:@"cdbQueryFailedEvent" 
		object:nil];

	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(clearDBTransasctionDidFailWithError:) 
		name:@"cdbTransactionFailedEvent" 
		object:nil];
 
 To handle these new observers, you can use the following methods as examples 
 to put into your own class:
 
	- (void)clearDBDidFinishQuery:(NSNotification *)notification {
		NSLog(@"Rows returned from ClearDB: %@", client.rows);
 
		// Here's an example for how to iterate through the result set 
		for (NSDictionary *row in client.rows) {
			NSLog(@"[%@] %@", 
			[row objectForKey:@"id"],
			[row objectForKey:@"username"]);
		}
		
	}
 
	- (void)clearDBDidFailWithError:(NSNotification *)notification {
		NSLog(@"ClearDB Client failed to connect to the ClearDB API: %@", notification);
	}
 
	- (void)clearDBQueryDidFailWithError:(NSNotification *)notification {
		NSLog(@"ClearDB query failed: %@", notification);
	}
 
	- (void)clearDBTransasctionDidFailWithError:(NSNotification *)notification {
		NSLog(@"ClearDB transaction failed: %@", notification);
	}
 
 
 Issuing Queries & Transactions
 ------------------------------
 Now that your client has been set up and initialized, your observers are defined, 
 and your event handler methods have been set up, it's time to start issuing 
 queries and transactions to ClearDB. 
 
 Here's an example of how to query your ClearDB database:
 
	[client query:@"SELECT * FROM test"];
 
 As soon as the query is executed and results are returned, the event handler for 
 handling the "cdbReadyEvent" will be raised. For example, with the code that 
 has been presented so far, the method clearDBDidFinishQuery will be called, 
 giving you a chance to retrieve the result NSMutableArray from the client, as 
 follows:

	NSLog(@"Rows returned from ClearDB: %@", client.rows);
 
 Transactions involve slightly more code, and ensure that your SQL statements are 
 wrapped in a transaction when sent to your ClearDB database. Here's an example 
 of a transaction statement set:
 
	[client startTransaction];
	[client query:@"DELETE FROM test"];
	[client query:@"INSERT INTO test(username, password) VALUES ('jim', 'jam')"];
	[client query:@"INSERT INTO test(username, password) VALUES ('bar', 'foo')"];
	[client sendTransaction];
 
 Once sendTransaction is called, the transaction will be sent to your ClearDB 
 database for processing. If an illegal statement, SQL syntax error, or Access 
 Rule violation occurrs, the "cdbTransactionFailedEvent" event will be raised, 
 calling the clearDBTransasctionDidFailWithError method (if so named from the 
 example) so that you can handle the error. 
 
 Note: by the time the "cdbTransactionFailedEvent" event is raised, ClearDB has 
 already rolled back your transaction, so you don't have to worry about manully 
 calling [cleardb rollbackTransaction]. In fact, you only need to call 
 rollbackTransaction in the event that something failed *prior to sending the 
 transaction to your ClearDB database*.
 
 Conclusion
 ----------
 We hope that you enjoy working with ClearDB, and this client! 
 
 Regards,
 The ClearDB Team.
 http://www.cleardb.com
 
 
 ******************************************************************************/


@interface ClearDBAppClient : NSObject {
	NSMutableData *payload;
	NSArray *rows;
	NSMutableArray *statements;
	NSString *API_KEY;
	NSString *APP_ID;
	BOOL inTransaction;
	NSURL *API_URL;
}

@property (nonatomic, retain) NSMutableData *payload;
@property (nonatomic, retain) NSString *API_KEY;
@property (nonatomic, retain) NSString *APP_ID;
@property (nonatomic, retain) NSArray *rows;

- (void) initializeClearDB;
- (void) query:(NSString *)sql;
- (void) sendTransaction;
- (void) startTransaction;
- (void) rollbackTransaction;

@end
