//
//  Ball.m
//  Labyrinth
//
//  Created by Akram on 9/3/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import "Ball.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "Wall.h"

@interface Ball()

@property int diameter;
@end

@implementation Ball

+ (Ball *) createBallWithPos:(CGPoint)pos andView:(UIView *)superView andDiameter:(int)diameter andImage:(UIImage *)ballImage
{
    Ball *ballInstance = [Ball new];
    ballInstance.diameter = diameter;
    ballInstance.myLayer = [CALayer new];
    ballInstance.myLayer.bounds = CGRectMake(0, 0, diameter, diameter);
    ballInstance.myLayer.position = pos;
    ballInstance.myLayer.delegate = ballInstance;
    [ballInstance.myLayer setNeedsDisplay];
    [superView.layer addSublayer:ballInstance.myLayer];
    if (ballImage) {
        __weak UIImage *layerImage = ballImage;
        CGImageRef image = [layerImage CGImage];
        [ballInstance.myLayer setContents:(__bridge id)image];
    }
    return ballInstance;
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, [[UIColor grayColor] CGColor]);
    CGContextFillEllipseInRect(ctx, self.myLayer.bounds);
}

- (void) moveBall:(CMAttitude *)attitude andWalls: (NSArray *) walls{
    double xPos = self.myLayer.position.x;
    double yPos = self.myLayer.position.y;
//    if (attitude.roll > 0.02 || attitude.roll < 0.0) {
//        xPos += attitude.roll * 10;
//    }
//    if (attitude.pitch > 0.02 || attitude.pitch < 0.0) {
//        yPos += attitude.pitch * 10;
//    }
    
    xPos += attitude.roll * 25;
    yPos += attitude.pitch * 25;
    
    for (Wall *wall in walls) {
        
        if (CGRectIntersectsRect(self.myLayer.frame, wall.myLayer.frame))
        {
            bool ballAboveWall = (self.myLayer.frame.origin.y - wall.myLayer.frame.origin.y < 0) ? true : false;
            bool ballLeftOfWall = (self.myLayer.frame.origin.x - wall.myLayer.frame.origin.x < 0) ? true : false;
            
            if (wall.horiz)
            {
                if (ballAboveWall)
                    yPos = wall.myLayer.frame.origin.y - wall.wallThickness/2 - self.diameter/2 - 0.0001;
                    //yPos -= attitude.pitch * 25;
                else
                    yPos = wall.myLayer.frame.origin.y + wall.wallThickness/2 + self.diameter/2 + 0.0001;
            } else {
                xPos -= attitude.roll *25;
            }
        }
    }
    
    if (xPos - self.diameter/2 < 0){
        xPos = 0 +self.diameter/2;
    } else if (xPos + self.diameter/2 > self.myLayer.superlayer.bounds.size.width) {
        xPos = self.myLayer.superlayer.bounds.size.width - self.diameter/2;
    }
    if (yPos - self.diameter/2 < 0){
        yPos = 0 +self.diameter/2;
    } else if (yPos + self.diameter/2 > self.myLayer.superlayer.bounds.size.height) {
        yPos = self.myLayer.superlayer.bounds.size.height - self.diameter/2;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
           self.myLayer.position = CGPointMake(xPos, yPos); 
    });

    
//    self.myLayer.position = CGPointMake(xPosStart, self.myLayer.superlayer.bounds.origin.x-self.diameter);
}
@end
