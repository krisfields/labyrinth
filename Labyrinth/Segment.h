//
//  Segment.h
//  Labyrinth
//
//  Created by Akram on 9/4/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Segment : NSObject
@property CGPoint startPt;
@property CGPoint endPt;
- (NSValue *) intersectsSegment: (Segment *) otherSegment andHoriz: (BOOL) horiz;
@end
