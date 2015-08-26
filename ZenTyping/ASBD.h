//
//  ASBD.h
//  AudioUnitPractice
//
//  Created by 村上 晋太郎 on 2014/02/21.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#ifndef AudioUnitPractice_ASBD_h
#define AudioUnitPractice_ASBD_h
#include <AudioToolbox/AudioToolbox.h>

extern AudioStreamBasicDescription AUCanonicalASBD(Float64 SampleRate, UInt32 Channel);
extern AudioStreamBasicDescription CanonicalASBD(Float64 SampleRate, UInt32 Channel);

#endif
