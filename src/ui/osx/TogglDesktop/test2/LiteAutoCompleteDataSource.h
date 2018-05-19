//
//  LiteAutoCompleteDataSource.h
//  TogglDesktop
//
//  Created by Indrek Vändrik on 23/02/2018.
//  Copyright © 2018 Alari. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "AutoCompleteInput.h"
#import "AutocompleteItem.h"
#import "AutoCompleteTableCell.h"

@interface LiteAutoCompleteDataSource : NSObject <NSTableViewDataSource>
@property NSMutableArray *orderedKeys;
@property NSMutableArray *filteredOrderedKeys;
@property NSMutableDictionary *dictionary;
@property NSString *currentFilter;
@property NSInteger textLength;
@property AutoCompleteInput *input;
@property NSInteger lastType;
@property NSString *lastClientLabel;
@property NSArray *types;
- (NSString *)completedString:(NSString *)partialString;
- (AutocompleteItem *)get:(NSString *)key;
- (void)setFilter:(NSString *)filter;
- (id)initWithNotificationName:(NSString *)notificationName;
- (AutocompleteItem *)itemAtIndex:(NSInteger)row;
@end
