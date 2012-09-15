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
#import "GameState.h"

@interface LabyrinthViewController () <UIAlertViewDelegate, GKSessionDelegate>
@property (strong) CMMotionManager* motionManager;
@property (strong) NSMutableArray *balls;
@property (strong) Ball *goal;
@property (strong) NSMutableArray *walls;
@property (strong) GKSession* session;
@property bool isClient;

@property GameState* myGameState;

@end

@implementation LabyrinthViewController
/*
 self.isGameSetup = NO;
 self.isReadyToPlay =  NO;
 self.isPlaying = NO;
 self.isGameEnd = NO;
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isClient = NO;
        self.session = [[GKSession alloc] initWithSessionID:@"Pokemon" displayName:@"Player" sessionMode:GKSessionModePeer];
        [self.session setDataReceiveHandler:self withContext:nil]; // Given to data whenever it's called. Not useful here.
        self.session.delegate = self;
        self.session.available = YES;
        [self.myGameState setGameState:isGameSetup];
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
    
    CGPoint centerOfView  = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    CGPoint bottomRightOfView = CGPointMake(self.view.bounds.size.width-18, self.view.bounds.size.height - 18);
    self.goal = [Ball createBallWithPos:bottomRightOfView andView:self.view andDiameter:35 andImage:nil];
    UIImage *ballImage = [UIImage imageNamed:@"ball.png"];
    Ball *ball = [Ball createBallWithPos:centerOfView andView:self.view andDiameter:30 andImage:ballImage];
    self.balls = [NSMutableArray new];
    [self.balls addObject:ball];
    
    NSArray *randomWalls = [Wall createRandomSolvableMazeWithNum:50 andView:self.view andBalls:self.balls];
    [self.walls addObjectsFromArray:randomWalls];
    
    
    
    self.motionManager = [CMMotionManager new];
    [self restartMotionManager];
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
                
                [self.myGameState setGameState:isGameEnd];
                [self sendMessageWithData:self.myGameState.encodeSelf];
                //[self sendMessage:@"You lost!"];
            }

        });
        [ball moveBall:motion.attitude andWalls:self.walls];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    for (Ball *ball in self.balls){
        
        CGPoint centerOfView  = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        ball.myLayer.position = centerOfView;
        [CATransaction commit];
        
        [self restartMotionManager];
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
    //self.isGameSetup = NO;
    NSLog(@"Did Receive Connection Request");
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    if (state == GKPeerStateAvailable) {
        NSLog(@"did Change State, state == GKPeerStateAvailable");
        // I found you. I want to connnect.
        [session connectToPeer:peerID withTimeout:2];

    } else if (state == GKPeerStateConnected) {
        NSLog(@"did Change State, state == GKPeerStateConnected");
        if (!self.isClient) {
            self.myGameState.walls = self.walls;
            [self.myGameState setGameState:isReadyToPlay];
            [self.session sendDataToAllPeers:self.myGameState.encodeSelf withDataMode:GKSendDataReliable error:nil];
        }
        session.available = NO;
    }
}

// ReveiveData, Delegate method. Mandatory for data handler.
-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"Receive data, isGameSetup is = %d", self.myGameState.isGameSetup);
    NSString* message;
    if (self.myGameState.isGameSetup) {
        if (self.isClient) {
            for (Wall *wall in self.walls){
                [wall.myLayer removeFromSuperlayer];
            };
            self.walls = nil;
            //self.walls = [unarchiver decodeObjectForKey:@"walls"];
            GameState *otherPlayerGameState = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.walls = (NSMutableArray *) otherPlayerGameState.walls;
            for (Wall *wall in self.walls) {
               [self.view.layer addSublayer:wall.myLayer];
                [wall.myLayer setNeedsDisplay];
            }
            [self.view setNeedsDisplay];
        }
        [self.myGameState setGameState:isReadyToPlay];
        // Communicate that client is ready to play
        [self.session sendDataToAllPeers:self.myGameState.encodeSelf withDataMode:GKSendDataReliable error:nil];
    }
    else
    {
        message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
        [[[UIAlertView alloc] initWithTitle:peer message:message delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];  
    }
}

// Send Data. Send message is custom
-(void)sendMessage:(NSString *)message {
    NSLog(@"send message: %@", message);
    NSData* payload = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.session sendDataToAllPeers:payload withDataMode:GKSendDataReliable error:nil];
}

-(void)sendMessageWithData: (NSData *) data
{
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

-(void) session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"In Failure, state == GKPeerStateAvailable");
    // I found you. I want to connnect.
    [session connectToPeer:peerID withTimeout:2];
}
@end
