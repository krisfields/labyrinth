//
//  GameState.h
//  Labyrinth
//
//  Created by Kris Fields on 9/5/12.
//  Copyright (c) 2012 Helou Services. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    isGameSetup,
    isReadyToPlay,
    isPlaying,
    isGameEnd
} gameProperty;

@interface GameState : NSObject <NSCoding>
@property bool isGameSetup;
@property bool isReadyToPlay;
@property bool isPlaying;
@property bool isGameEnd;
@property NSArray *walls;
-(NSData *) encodeSelf;
-(void) setGameState: (gameProperty) gameProperty;
-(void) resetGameState;
@end
