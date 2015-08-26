//
//  Synth.m
//  MuraSynth
//
//  Created by 村上 晋太郎 on 2014/02/03.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#import "WaveSynth.h"
#define BUFFER_NUM 3
#define NUM_PACKETS_TO_READ 512

@interface WaveSynth ()
@property (nonatomic) AudioQueueRef audioQueueObject;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isPlaying;
@end

@implementation WaveSynth

/// 正規化されたシグモイド曲線
static float sygmoid_reg(double x, double a){
    return sygmoid(x, a) / sygmoid(1, a);
}

static float sygmoid(double x, double a){
    return 1. / (1 + exp(-a * x));
}

static void outputCallBack(void * inUserData,
                           AudioQueueRef inAQ,
                           AudioQueueBufferRef inBuffer)
{
    WaveSynth * synth = (__bridge WaveSynth *)inUserData;
    UInt32 numPackets = synth.numPacketsToRead;
    
    UInt32 numBytes = numPackets * sizeof(SInt16);
    
    float phase_delta = synth.freq * 2.0 * M_PI / 44100.;
    SInt16 * output = inBuffer->mAudioData;
    double phase = synth.phase;
    double sharpness = synth.sharpness;
    for (int i = 0; i < numPackets; i++){
        float wave = sygmoid_reg(sin(phase), sharpness);
        SInt16 sample = wave * 32767;
        *output++ = sample;
        phase += phase_delta;
    }
    synth.phase = phase;
    
    inBuffer->mAudioDataByteSize = numBytes;
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

-(id)init
{
    self = [super init];
    if(self){
        [self prepareAudioQueue];
        _freq = 420.;
        _sharpness = 1;
        
    }
    return self;
}

-(void)prepareAudioQueue
{
    // ASBD
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 44100.;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags =
    kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerPacket = 2;
    audioFormat.mBytesPerFrame = 2;
    audioFormat.mReserved = 0;
    
    AudioQueueNewOutput( &audioFormat,
                        (AudioQueueOutputCallback) outputCallBack,
                        (__bridge void *)self,
                        NULL, NULL, 0,
                        &(_audioQueueObject));
    
    AudioQueueBufferRef buffers[BUFFER_NUM];
    _numPacketsToRead = NUM_PACKETS_TO_READ;
    UInt32 bufferByteSize = _numPacketsToRead * audioFormat.mBytesPerPacket;
    
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < BUFFER_NUM; bufferIndex++){
        AudioQueueAllocateBuffer(_audioQueueObject,
                                 bufferByteSize,
                                 &buffers[bufferIndex]);
        outputCallBack((__bridge void *)(self), _audioQueueObject, buffers[bufferIndex]);
    }
    _isPrepared = YES;
}

-(void)play
{
    if(!_isPrepared) [self prepareAudioQueue];
    AudioQueueStart(_audioQueueObject, NULL);
    _isPlaying = YES;
}

// バックグラウンドからの復帰など
-(void)restartAudioQueue {
    if(_isPlaying) {
        AudioQueueStart(_audioQueueObject, NULL);
    }
}

-(void)stop:(BOOL)shouldStopImmideately
{
    AudioQueueStop(_audioQueueObject, shouldStopImmideately);
    AudioQueueDispose( _audioQueueObject, shouldStopImmideately);
    _audioQueueObject = NULL;
    _isPrepared = NO;
    _isPlaying = NO;
}

-(void)dealloc {
    if(_audioQueueObject)
        AudioQueueDispose(_audioQueueObject, YES);
}
@end
