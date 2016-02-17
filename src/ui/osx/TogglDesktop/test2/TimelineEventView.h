//
//  TimelineEventView.h
//  TogglDesktop
//
//  Created by Tanel Lebedev on 26/10/15.
//  Copyright © 2015 Toggl Desktop Developers. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "toggl_api.h"

@interface TimelineEventView : NSObject
- (void)load:(TogglTimelineEventView *)data;
- (NSMutableAttributedString *)descriptionString;
@property (strong) NSString *Title;
@property (strong) NSString *Filename;
@property int64_t Duration;
@end
