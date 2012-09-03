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
#import <QuartzCore/QuartzCore.h>

@interface LabyrinthViewController () <UIAlertViewDelegate>
@property (strong) CMMotionManager* motionManager;
@property (strong) NSMutableArray *balls;
@property (strong) Ball *goal;

@end

@implementation LabyrinthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGPoint centerOfView  = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    CGPoint bottomRightOfView = CGPointMake(self.view.bounds.size.width-18, self.view.bounds.size.height - 18);
    self.goal = [Ball createBallWithPos:bottomRightOfView andView:self.view andDiameter:35 andImage:nil];
    UIImage *ballImage = [UIImage imageNamed:@"ball.png"];
    Ball *ball = [Ball createBallWithPos:centerOfView andView:self.view andDiameter:30 andImage:ballImage];

    self.balls = [NSMutableArray new];
    [self.balls addObject:ball];
    
    self.motionManager = [CMMotionManager new];
    [self.motionManager startDeviceMotionUpdates];
    NSTimeInterval updateInterval = .1;
    self.motionManager.deviceMotionUpdateInterval = updateInterval;
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    CMDeviceMotionHandler motionBlock = ^void(CMDeviceMotion *motion, NSError *error)
    {
        [self handleMotionEventsWithMotion:motion andError:error];
    };
    
   [self.motionManager startDeviceMotionUpdatesToQueue:backgroundQueue withHandler:motionBlock];
    
//    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:motionBlock];
    
    
    
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
    for (Ball* ball in self.balls) {
        NSLog(@"Ball bounds Xpos is =  %f", ball.myLayer.bounds.origin.x);
        NSLog(@"Ball bounds Ypos is =  %f", ball.myLayer.bounds.origin.y);
        NSLog(@"Goal bounds Xpos is =  %f", self.goal.myLayer.bounds.origin.x);
        NSLog(@"Goal bounds Ypos is =  %f", self.goal.myLayer.bounds.origin.y);
        if (CGRectIntersectsRect(self.goal.myLayer.bounds, ball.myLayer.bounds)) {
            UIAlertView* popup = [[UIAlertView alloc] initWithTitle:@"You won!" message:@"It wasn't that hard though." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [popup show];
        }
        [ball moveBall:motion.attitude];
    }
//    NSLog(@"Roll is %f", motion.attitude.roll);
//    NSLog(@"Yaw is %f", motion.attitude.yaw);
//    NSLog(@"PItch is %f", motion.attitude.pitch);
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //    self.window.rootViewController.view = [[AsteroidsView alloc] initWithFrame:self.window.bounds];
    
    for (Ball *ball in self.balls){
        ball.myLayer.bounds = CGRectMake(self.view.bounds.size
                                         .width-ball.myLayer.bounds.size.width/2, self.view.bounds.size
                                         .height-ball.myLayer.bounds.size.height/2, ball.myLayer.bounds.size.width, ball.myLayer.bounds.size.height);
    }
    
    
}
@end
