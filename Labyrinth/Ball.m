//
//  Ball.m
//  Labyrinth
//
//  Created by Akram on 9/3/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import "Ball.h"
#import <QuartzCore/QuartzCore.h>

@interface Ball()
@property (strong) CALayer *myLayer;
@property int diameter;
@end

@implementation Ball

+ (Ball *) createBallWithPos:(CGPoint)pos andView:(UIView *)superView andDiameter:(int)diameter
{
    Ball *ballInstance = [Ball new];
    ballInstance.diameter = diameter;
    ballInstance.myLayer = [CALayer new];
    ballInstance.myLayer.bounds = CGRectMake(0, 0, diameter, diameter);
    ballInstance.myLayer.position = pos;
    ballInstance.myLayer.delegate = ballInstance;
    [ballInstance.myLayer setNeedsDisplay];
    [superView.layer addSublayer:ballInstance.myLayer];
    return ballInstance;
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, [[UIColor grayColor] CGColor]);
    CGContextFillEllipseInRect(ctx, self.myLayer.bounds);
}

@end
