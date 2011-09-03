//
//  Autocomplete.m
//
//  Created by Radu Lucaciu on 8/17/10.
//  Copyright 2010. All rights reserved.
//

#import "Autocomplete.h"


@implementation Autocomplete

- (Autocomplete *)initWithArray:(NSArray *)initialArray
{
	candidates = [[NSMutableArray alloc] initWithArray:initialArray];
	[candidates sortUsingSelector:@selector(compare:)];
	
	return self;
}

- (NSMutableArray *)GetSuggestions:(NSString *)root
{
	//Search for the first item that matches the root
	int start = 0;
	int end = [candidates count] - 1;
	int foundStartIndex = -1;
	int foundEndIndex = -1;
	
	//Find the first element that matches the string
	while (start != end)
	{
		int position = (start + end) / 2;
		NSString *candidate = [candidates objectAtIndex:position];
		
		if ([candidate length] < [root length])
		{
			if ([candidate caseInsensitiveCompare:root] == NSOrderedDescending)
			{
				if (end == position)
				{
					break;
				}
				end = position;
			}
			else
			{
				if (start == position)
				{
					break;
				}
				start = position;
			}
		}
		else
		{
			if ([[candidate substringToIndex:[root length]] caseInsensitiveCompare:root] == NSOrderedSame)
			{
				foundStartIndex = position;
				if (end == position)
				{
					break;
				}
				end = position;
			}
			else
			{
				if ([candidate caseInsensitiveCompare:root] == NSOrderedAscending)
				{
					if (start == position)
					{
						break;
					}
					start = position;
				}
				else
				{
					if (end == position)
					{
						break;
					}
					end = position;
				}
			}
		}
	}
	
	
	//Find the last element that matches the string
	start = 0;
	end = [candidates count] - 1;
	while (start != end)
	{
		int position = (start + end) / 2;
		NSString *candidate = [candidates objectAtIndex:position];
		
		if ([candidate length] < [root length])
		{
			if ([candidate caseInsensitiveCompare:root] == NSOrderedDescending)
			{
				if (end == position)
				{
					break;
				}
				end = position;
			}
			else
			{
				if (start == position)
				{
					break;
				}
				start = position;
			}
		}
		else
		{
			if ([[candidate substringToIndex:[root length]] caseInsensitiveCompare:root] == NSOrderedSame)
			{
				foundEndIndex = position;
				if (start == position)
				{
					break;
				}
				start = position;
			}
			else
			{
				if ([candidate caseInsensitiveCompare:root] == NSOrderedAscending)
				{
					if (start == position)
					{
						break;
					}
					start = position;
				}
				else
				{
					if (end == position)
					{
						break;
					}
					end = position;
				}
			}
		}
	}
	
	
	
	NSMutableArray *suggestions = [[NSMutableArray alloc] init];
	
	if (foundStartIndex != -1 && foundEndIndex != -1)
	{
		for (int i = foundStartIndex; i <= foundEndIndex; i++)
		{
			[suggestions addObject:[candidates objectAtIndex:i]];
		 }
	}
	
	return [suggestions autorelease];
}

- (void)AddCandidate:(NSString *)candidate
{
	//Is the candidate already in the list?
	for (int i = 0; i < [candidates count]; i++)
	{
		if ([[candidates objectAtIndex:i] isEqualToString:candidate])
		{
			return;
		}
	}
	
	//Add the new candidate
	[candidates addObject:[candidate copy]];
	[candidates sortUsingSelector:@selector(compare:)];
}

- (void)dealloc
{
	[candidates release];
	[super dealloc];
}	

@end
