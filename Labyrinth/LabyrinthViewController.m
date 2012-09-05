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
#import <GameKit/GameKit.h>

@interface LabyrinthViewController () <UIAlertViewDelegate, GKSessionDelegate>
@property (strong) CMMotionManager* motionManager;
@property (strong) NSMutableArray *balls;
@property (strong) Ball *goal;
@property (strong) NSMutableArray *walls;
@property (strong) GKSession* session;
@property bool isClient;
@property bool isGameStart;

@end

@implementation LabyrinthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        LabyrinthView *lv = [LabyrinthView new] ;
//        self.view = lv;
        self.isClient = NO;
        self.isGameStart = YES;
        self.session = [[GKSession alloc] initWithSessionID:@"Pokemon" displayName:@"Player" sessionMode:GKSessionModePeer];
        [self.session setDataReceiveHandler:self withContext:nil]; // Given to data whenever it's called. Not useful here.
        self.session.delegate = self;
        self.session.available = YES;
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
//    
//    CGPoint wallStart = CGPointMake(self.view.bounds.size.width*1/4, self.view.bounds.size.height*2/3);
//    Wall * wall = [Wall createWallWithStart:wallStart andLength:self.view.bounds.size.width/2 andHoriz:YES andView:self.view];
//    [self.walls addObject:wall];
//  
//    wallStart = CGPointMake(self.view.bounds.size.width*1/4, self.view.bounds.size.height*2/3+10);
//    Wall * wall2 = [Wall createWallWithStart:wallStart andLength:self.view.bounds.size.width/2 andHoriz:YES andView:self.view];
//    [self.walls addObject:wall2];
//    
//    wallStart = CGPointMake(self.view.bounds.size.width*1/8, self.view.bounds.size.height*2/3+10);
//    Wall * wall3 = [Wall createWallWithStart:wallStart andLength:self.view.bounds.size.width/2 andHoriz:NO andView:self.view];
//    [self.walls addObject:wall3];
//    
//    wallStart = CGPointMake(self.view.bounds.size.width*7/8, self.view.bounds.size.height*2/3+10);
//    Wall * wall4 = [Wall createWallWithStart:wallStart andLength:self.view.bounds.size.width/2 andHoriz:NO andView:self.view];
//    [self.walls addObject:wall4];
    
    CGPoint centerOfView  = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    CGPoint bottomRightOfView = CGPointMake(self.view.bounds.size.width-18, self.view.bounds.size.height - 18);
    self.goal = [Ball createBallWithPos:bottomRightOfView andView:self.view andDiameter:35 andImage:nil];
    UIImage *ballImage = [UIImage imageNamed:@"ball.png"];
    Ball *ball = [Ball createBallWithPos:centerOfView andView:self.view andDiameter:30 andImage:ballImage];
    self.balls = [NSMutableArray new];
    [self.balls addObject:ball];
    
//    NSArray *randomWalls = [Wall createRandomWallsWithNum:15 andView:self.view andBalls:self.balls];
    NSArray *randomWalls = [Wall createRandomSolvableMazeWithNum:50 andView:self.view andBalls:self.balls];
    [self.walls addObjectsFromArray:randomWalls];
    
    
    
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
                UIAlertView* popup = [[UIAlertView alloc] initWithTitle:@"You won!" message:@"Play Again?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [self.motionManager stopDeviceMotionUpdates];
                [popup show];
                [self sendMessage:@"You lost!"];
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

// Mandatory delegate method
-(void)session:(GKSession*)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    [self.session acceptConnectionFromPeer:peerID error:nil];
    session.available = NO;
    self.isClient = YES;
    //self.isGameStart = NO;
    NSLog(@"Did Receive Connection Request");
    
//    [self logToView:[NSString stringWithFormat:@"Connecting client: %@\n", peerID]];
    //  [self sendMessage:@"Hello client!" toPeer:peerID];
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    if (state == GKPeerStateAvailable) {
//        [self logToView:[NSString stringWithFormat:@"Connecting to peer: %@\n", peerID]];
        NSLog(@"did Change State, state == GKPeerStateAvailable");
        // I found you. I want to connnect.
        [session connectToPeer:peerID withTimeout:2];

    } else if (state == GKPeerStateConnected) {
        NSLog(@"did Change State, state == GKPeerStateConnected");
        if (!self.isClient) {
            NSMutableData *data = [[NSMutableData alloc] init];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [archiver encodeObject:self.walls forKey:@"walls"];
            [archiver finishEncoding];
            [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
        }
        // State happens three times. Available, connected, and Disconnected.
//        [self logToView:[NSString stringWithFormat:@"Connected to peer: %@\n", peerID]];
        //    [self sendMessage:@"Hello peer!" toPeer:peerID];
        
        // only connect two players
//                [self sendMessage];
        
        session.available = NO;
    }
}

// ReveiveData, Delegate method. Mandatory for data handler.
-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"Receive data, isGameStart is = %d", self.isGameStart);
    NSString* message;
    if (self.isGameStart) {
        if (self.isClient) {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            for (Wall *wall in self.walls){
                [wall.myLayer removeFromSuperlayer];
            };
            self.walls = nil;
            self.walls = [unarchiver decodeObjectForKey:@"walls"];
            for (Wall *wall in self.walls) {
               [self.view.layer addSublayer:wall.myLayer];
                [wall.myLayer setNeedsDisplay];
            }
            [self.view setNeedsDisplay];
            [unarchiver finishDecoding];
        }
        self.isGameStart = NO;
        message = @"Start!";
    } else {
        message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
        [[[UIAlertView alloc] initWithTitle:peer message:message delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
}

// Send Data. Send message is custom
-(void)sendMessage:(NSString *)message {
    NSLog(@"send message: %@", message);
//    NSString *message = @"Test message"
    ;    // Convert data to bytes
    NSData* payload = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    // This is where the magic happens. Send the payload to everyone.
    // You can send it to individual peers as well.
    // Data Mode: Unreliable or reliable. Reliable: They'll always be received in order.
    // Unreliable: If it's ok once in a while to lose a message, or come in out of order. Generally faster. Not worth it here.
    [self.session sendDataToAllPeers:payload withDataMode:GKSendDataReliable error:nil];
}
@end
