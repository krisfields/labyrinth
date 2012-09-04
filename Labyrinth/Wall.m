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
#import "Ball.h"

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

+(NSArray *) createRandomWallsWithNum: (int) num andView: (UIView *)superView andBalls:(NSArray *)balls
{
    NSMutableArray *walls = [NSMutableArray new];
    CGPoint randStartPt;
    CGFloat randLength;
    bool randHoriz;
    int i = 0;
    while(i<num)
    {
        randStartPt = CGPointMake((arc4random()/(double)UINT_MAX)*superView.frame.size.width, (arc4random()/(double)UINT_MAX)*superView.frame.size.height);
        randHoriz = arc4random()%2;
        if (randHoriz)
            randLength = (arc4random()/(double)UINT_MAX)*(superView.frame.size.width*3/4);
        else
            randLength = (arc4random()/(double)UINT_MAX)*(superView.frame.size.height*3/4);
        
        Wall *wallInstance = [Wall createWallWithStart:randStartPt andLength:randLength andHoriz:randHoriz andView:superView];
        
        bool interesects = NO;
        for (Ball *ball in balls)
        {
            if (CGRectIntersectsRect(wallInstance.myLayer.frame, ball.myLayer.frame) )
            {
                interesects = YES;
                break;
            }
        }
        if (!interesects)
        {
             [wallInstance.myLayer setNeedsDisplay];
            [walls addObject:wallInstance];
            i++;
        }
    }
    return walls;
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    CGContextFillRect(ctx, self.myLayer.bounds);
}

@end
