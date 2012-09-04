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
#import "LabyrinthView.h"
#import "Wall.h"

@interface LabyrinthViewController () <UIAlertViewDelegate>
@property (strong) CMMotionManager* motionManager;
@property (strong) NSMutableArray *balls;
@property (strong) Ball *goal;
@property (strong) NSMutableArray *walls;

@end

@implementation LabyrinthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        LabyrinthView *lv = [LabyrinthView new] ;
//        self.view = lv;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    LabyrinthView *lv = [[LabyrinthView alloc] initWithFrame:[UIScreen mainScreen].bounds] ;
    
    self.view = lv;

	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.walls = [NSMutableArray new];
    
//    CGPoint wallStart = CGPointMake(self.view.bounds.size.width*1/4, self.view.bounds.size.height*2/3);
//    Wall * wall = [Wall createWallWithStart:wallStart andLength:self.view.bounds.size.width/2 andHoriz:YES andView:self.view];
//    [self.walls addObject:wall];
//    
//    wallStart = CGPointMake(self.view.bounds.size.width*1/4, self.view.bounds.size.height*2/3+10);
//    wall = [Wall createWallWithStart:wallStart andLength:self.view.bounds.size.width/2 andHoriz:YES andView:self.view];
//    [self.walls addObject:wall];
    
    CGPoint centerOfView  = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    CGPoint bottomRightOfView = CGPointMake(self.view.bounds.size.width-18, self.view.bounds.size.height - 18);
    self.goal = [Ball createBallWithPos:bottomRightOfView andView:self.view andDiameter:35 andImage:nil];
    UIImage *ballImage = [UIImage imageNamed:@"ball.png"];
    Ball *ball = [Ball createBallWithPos:centerOfView andView:self.view andDiameter:30 andImage:ballImage];
    
    NSArray *randomWalls = [Wall createRandomWallsWithNum:15 andView:self.view andBalls:self.balls];
    [self.walls addObjectsFromArray:randomWalls];
    
    

    self.balls = [NSMutableArray new];
    [self.balls addObject:ball];
    
    self.motionManager = [CMMotionManager new];
    [self restartMotionManager];
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (CGRectContainsRect(self.goal.myLayer.frame, ball.myLayer.frame))
            {
                UIAlertView* popup = [[UIAlertView alloc] initWithTitle:@"You won!" message:@"It wasn't that hard though." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [self.motionManager stopDeviceMotionUpdates];
                [popup show];
                
            }

        });
        [ball moveBall:motion.attitude andWalls:self.walls];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //    self.window.rootViewController.view = [[AsteroidsView alloc] initWithFrame:self.window.bounds];
    
    for (Ball *ball in self.balls){
        
        CGPoint centerOfView  = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        ball.myLayer.position = centerOfView;
        [CATransaction commit];
        
        [self restartMotionManager];
        
//        ball.myLayer.bounds = CGRectMake(self.view.bounds.size
//                                         .width-ball.myLayer.bounds.size.width/2, self.view.bounds.size
//                                         .height-ball.myLayer.bounds.size.height/2, ball.myLayer.bounds.size.width, ball.myLayer.bounds.size.height);
    }
    
    
}

- (void) restartMotionManager
{
    [self.motionManager startDeviceMotionUpdates];
    NSTimeInterval updateInterval = 0.1;
    self.motionManager.deviceMotionUpdateInterval = updateInterval;
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    CMDeviceMotionHandler motionBlock = ^void(CMDeviceMotion *motion, NSError *error)
    {
        [self handleMotionEventsWithMotion:motion andError:error];
    };
    
    [self.motionManager startDeviceMotionUpdatesToQueue:backgroundQueue withHandler:motionBlock];

}
@end
