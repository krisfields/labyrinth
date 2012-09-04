//
//  Wall.h
//  Labyrinth
//
//  Created by Akram on 9/3/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CALayer;

@interface Wall : NSObject
+(Wall *) createWallWithStart:(CGPoint)startPt andLength: (CGFloat) length andHoriz: (bool) horiz andView:(UIView *)superView;
+(NSArray *) createRandomWallsWithNum: (int) num andView: (UIView *)superView andBalls: (NSArray *) balls;
@property CALayer* myLayer;
@property bool horiz;
@property CGFloat wallThickness;
@end
