//
//  AudioBufferList.h
//  WaveView
//
//  Created by 村上 晋太郎 on 2014/03/06.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

AudioBufferList * allocateAudioBufferList(UInt32 numChannels, UInt32 size);
void removeAudioBufferList(AudioBufferList * list);

