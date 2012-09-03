//
//  Ball.h
//  Labyrinth
//
//  Created by Akram on 9/3/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ball : NSObject
+ (Ball *) createBallWithPos:(CGPoint)pos andView:(UIView *)superView andDiameter:(int)diameter;
@end
