//
//  Ball.h
//  Labyrinth
//
//  Created by Akram on 9/3/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CMAttitude;

@interface Ball : NSObject
@property (strong) CALayer *myLayer;
@property int diameter;

+ (Ball *) createBallWithPos:(CGPoint)pos andView:(UIView *)superView andDiameter:(int)diameter andImage:(UIImage *)ballImage;
- (void) moveBall:(CMAttitude *)attitude andWalls: (NSArray *) walls;
@end
