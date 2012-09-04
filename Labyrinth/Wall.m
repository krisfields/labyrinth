//
//  Wall.m
//  Labyrinth
//
//  Created by Akram on 9/3/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import "Wall.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

@interface Wall()

@end

@implementation Wall

+(Wall *) createWallWithStart:(CGPoint)startPt andLength: (CGFloat) length andHoriz: (bool) horiz andView:(UIView *)superView
{
    Wall *wallInstance = [Wall new];
    wallInstance.horiz = horiz;
    wallInstance.wallThickness = 5;
    wallInstance.myLayer = [CALayer new];
    if (horiz)
    {
        wallInstance.myLayer.bounds = CGRectMake(0, 0, length , wallInstance.wallThickness);
        wallInstance.myLayer.position = CGPointMake(startPt.x + length/2, startPt.y + wallInstance.wallThickness/2);
    }
    else
    {
        wallInstance.myLayer.bounds = CGRectMake(0, 0, wallInstance.wallThickness, length);
        wallInstance.myLayer.position = CGPointMake(startPt.x + wallInstance.wallThickness/2, startPt.y + length/2);
    }
    
    wallInstance.myLayer.delegate = wallInstance;
    [wallInstance.myLayer setNeedsDisplay];
    [superView.layer addSublayer:wallInstance.myLayer];
    return wallInstance;
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    CGContextFillRect(ctx, self.myLayer.bounds);
}

@end
