//
//  ASBD.c
//  AudioUnitPractice
//
//  Created by 村上 晋太郎 on 2014/02/21.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#include <stdio.h>
#include "ASBD.h"

AudioStreamBasicDescription AUCanonicalASBD(Float64 sampleRate, UInt32 channel)
{
  AudioStreamBasicDescription audioFormat;
  audioFormat.mSampleRate = sampleRate;
  audioFormat.mFormatID = kAudioFormatLinearPCM;
  audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift); // kAudioFormatFlagsAudioUnitCanonical;
  audioFormat.mChannelsPerFrame = channel;
  audioFormat.mBytesPerPacket = sizeof(SInt32);
  audioFormat.mBytesPerFrame = sizeof(SInt32);
  audioFormat.mFramesPerPacket = 1;
  audioFormat.mBitsPerChannel = 8 * sizeof(SInt32);
  audioFormat.mReserved = 0;
  return audioFormat;
}

AudioStreamBasicDescription CanonicalASBD(Float64 sampleRate, UInt32 channel)
{
  AudioStreamBasicDescription audioFormat;
  audioFormat.mSampleRate = sampleRate;
  audioFormat.mFormatID = kAudioFormatLinearPCM;
  audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked; //  kAudioFormatFlagsCanonical;
  audioFormat.mChannelsPerFrame = channel;
  audioFormat.mBytesPerPacket = sizeof(SInt32) * channel;
  audioFormat.mBytesPerFrame = sizeof(SInt32) * channel;
  audioFormat.mFramesPerPacket = 1;
  audioFormat.mBitsPerChannel = 8 * sizeof(SInt32);
  audioFormat.mReserved = 0;
  return audioFormat;
}