//
//  GameState.m
//  Labyrinth
//
//  Created by Kris Fields on 9/5/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import "GameState.h"

@implementation GameState

-(void)encodeWithCoder:(NSCoder *)aCoder {
    // The key doesn't matter, but it has to be the same on both ends.
    // of encode and decode.
    [aCoder encodeBool:self.isGameSetup forKey:@"isGameSetup"];
    [aCoder encodeBool:self.isPlaying forKey:@"isPlaying"];
     [aCoder encodeBool:self.isGameEnd forKey:@"isGameEnd"];
}

// This only gets called when it's decoded.
-(id)initWithCoder:(NSCoder *)aDecoder {
    // super init like any ol' init.
    self = [super init];
    
    if (self) {
        
        self.isGameSetup = [aDecoder decodeBoolForKey:@"isGameSetup"];
        self.isPlaying = [aDecoder decodeBoolForKey:@"isPlaying"];
        self.isGameEnd = [aDecoder decodeBoolForKey:@"isGameEnd"];
    }
    
    return self;
}

-(NSData *)encodeSelf
{
    NSData* gameStateData = [NSKeyedArchiver archivedDataWithRootObject:self];
    return gameStateData;
}

-(void) resetGameState
{
    self.isGameSetup = NO;
    self.isReadyToPlay =  NO;
    self.isPlaying = NO;
    self.isGameEnd = NO;
}

-(void) setGameState:(gameProperty)gameProperty
{
    [self resetGameState];
    if (gameProperty == isGameSetup)
        self.isGameSetup = YES;
    else if (gameProperty == isReadyToPlay)
        self.isReadyToPlay = YES;
    else if (gameProperty == isPlaying)
        self.isPlaying = YES;
    else if (gameProperty == isGameEnd)
        self.isGameEnd = YES;
}
@end
