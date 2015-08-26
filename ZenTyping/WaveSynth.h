//
//  Synth.h
//  MuraSynth
//
//  Created by 村上 晋太郎 on 2014/02/03.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolBox/AudioToolbox.h>

@interface WaveSynth : NSObject
@property (nonatomic) UInt32 numPacketsToRead;
@property (nonatomic) double phase;
@property (nonatomic) double freq;
@property (nonatomic) double sharpness;

-(void)prepareAudioQueue;
-(void)play;
-(void)restartAudioQueue; // return from background
-(void)stop:(BOOL)shouldStopImmideately;

@end
