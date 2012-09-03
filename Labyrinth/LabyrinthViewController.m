//
//  LabyrinthViewController.m
//  Labyrinth
//
//  Created by Akram on 9/3/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import "LabyrinthViewController.h"
#import "Ball.h"
#import <CoreMotion/CoreMotion.h>

@interface LabyrinthViewController ()
@property (strong) CMMotionManager* motionManager;
@property (strong) NSMutableArray *balls;

@end

@implementation LabyrinthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.motionManager = [CMMotionManager new];
    [self.motionManager startDeviceMotionUpdates];
    NSTimeInterval updateInterval = 0.1;
    self.motionManager.deviceMotionUpdateInterval = updateInterval;
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    CMDeviceMotionHandler motionBlock = ^void(CMDeviceMotion *motion, NSError *error)
    {
        [self handleMotionEventsWithMotion:motion andError:error];
    };
    
   [self.motionManager startDeviceMotionUpdatesToQueue:backgroundQueue withHandler:motionBlock];
    
    CGPoint centerOfView  = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    Ball *ball = [Ball createBallWithPos:centerOfView andView:self.view andDiameter:30];
    [self.balls addObject:ball];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) handleMotionEventsWithMotion:(CMDeviceMotion*) motion andError: (NSError*) error
{
    
}

@end
