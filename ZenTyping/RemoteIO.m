//
//  RemoteIO.m
//  WaveView
//
//  Created by 村上 晋太郎 on 2014/03/04.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#import "RemoteIO.h"
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ASBD.h"
#import "AudioBufferList.h"
#define SAMPLE_RATE 44100.0

@interface RemoteIO()
@property (nonatomic) AUGraph auGraph;
@property (nonatomic) BOOL isPlaying;
@end

// =======================
// 波形解析へのデータの受け渡し
// =======================
static OSStatus sendWave(void * inRefCon,
                         AudioUnitRenderActionFlags * ioActionFlags,
                         const AudioTimeStamp * inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList * ioData)
{
    RemoteIO * __self__ = (__bridge RemoteIO *)inRefCon;
    
    // Allocate buffer list
    if (!__self__.bufferList){
        __self__.bufferList = allocateAudioBufferList(1, sizeof(SInt32) * inNumberFrames);
    }
    
    // Data buffer
    AudioBufferList * data = __self__.bufferList;
    
    // Render input wave
    OSStatus err = AudioUnitRender(__self__.remoteIOUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, data);
    if (err) {
        printf("sendWave: error\n");
        return err;
    }
    
    // Send wave to wave view
    SInt32 *input = data->mBuffers[0].mData;
//    [__self__.waveManager setWave:input];
    
    return noErr;
};

// ====================
// スピーカーのループの駆動
// ====================
static OSStatus outCallback (void * inRefCon,
                             AudioUnitRenderActionFlags * ioActionFlags,
                             const AudioTimeStamp * inTimeStamp,
                             UInt32 inBusNumber,
                             UInt32 inNumberFrames,
                             AudioBufferList * ioData)
{
    // send input wave to wave view
    sendWave(inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, NULL);
    
    return noErr;
}


@implementation RemoteIO
- (id) init {
    self = [super init];
    
    if (self) {
        [self prepareAUGraph];
    }
    
    return  self;
}

- (void) prepareAUGraph {
    AUNode remoteIONode;
    
    // backgroundからの復帰で呼ばれたときなど。
    if (_auGraph) {
        [self releaseAUGraph:_auGraph];
        _auGraph = NULL;
    }
    
    NewAUGraph(&_auGraph);
    AUGraphOpen(_auGraph);
    
    // Create Remote IO Node and Remote IO Unit
    AudioComponentDescription cd;
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = cd.componentFlagsMask = 0;
    
    AUGraphAddNode(_auGraph, &cd, &remoteIONode);
    AUGraphNodeInfo(_auGraph, remoteIONode, NULL, &_remoteIOUnit);
    
    // Enable microphone input
    [self enableMicrophoneInput:YES];
    
    // ASBD
    AudioStreamBasicDescription audioFormat = AUCanonicalASBD(SAMPLE_RATE, 1);
    
    // Set stream format to monoral CanonicalASBD
    AudioUnitSetProperty(_remoteIOUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         1, // Remote Input
                         &audioFormat,
                         sizeof(audioFormat));
    
    AudioUnitSetProperty(_remoteIOUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0, // Remote Output
                         &audioFormat,
                         sizeof(audioFormat));
    
    cd.componentType = kAudioUnitType_Mixer;
    cd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    
    AUNode multiChannelMixerNode;
    AudioUnit multiChannelMixerUnit;
    
    AUGraphAddNode(_auGraph, &cd, &multiChannelMixerNode);
    AUGraphNodeInfo(_auGraph, multiChannelMixerNode, NULL, &multiChannelMixerUnit);
    
    
    // Connect Remote Input to multi channel mixer Unit
    
    AUGraphConnectNodeInput(_auGraph,
                            remoteIONode,
                            1, // Remote Input
                            multiChannelMixerNode,
                            0); // Bus 0
    
    // Connect Remote Input to Remote Output
    //  AUGraphConnectNodeInput(_auGraph,
    //                          remoteIONode,
    //                          1, // Remote Input
    //                          remoteIONode,
    //                          0); // Remote Output
    
    // Set Callback Function
    //  AUGraphAddRenderNotify(_auGraph, inputCallback, (__bridge void *)(self));
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = outCallback;
    callbackStruct.inputProcRefCon = (__bridge void *) self;
    
    AudioUnitSetProperty(_remoteIOUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         0, // Remote Input
                         &callbackStruct,
                         sizeof(callbackStruct));
    
    //  AUGraphSetNodeInputCallback(_auGraph, remoteIONode, 0, &callbackStruct);
    //  AUGraphSetNodeInputCallback(_auGraph, multiChannelMixerNode, 0, &callbackStruct);
    
    AUGraphInitialize(_auGraph);
    
}

- (void) enableMicrophoneInput:(BOOL)enabled
{
    // Enable microphone input
    UInt32 flag = enabled;
    AudioUnitSetProperty(_remoteIOUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         1, // Remote Input
                         &flag,
                         sizeof(flag));
}

- (void) start {
    if (!_isPlaying) {
        [self enableMicrophoneInput:YES];
        AUGraphInitialize(_auGraph);
        AUGraphStart(_auGraph);
    }
    _isPlaying = YES;
}

// バックグラウンドからの復旧
- (void)restartAUGraph {
    if(_isPlaying) {
        [self prepareAUGraph]; // 普通にAUGraphStartdしても正常に復旧しなかったため、いったんAUGraph自体を作り直している。
        [self enableMicrophoneInput:YES];
        AUGraphInitialize(_auGraph);
    }
}

- (void) stop {
    if(_isPlaying) {
        AUGraphStop(_auGraph);
        [self enableMicrophoneInput:NO];
        AUGraphInitialize(_auGraph);
    }
    _isPlaying = NO;
}

- (void)releaseAUGraph:(AUGraph)graph {
    AUGraphUninitialize(graph);
    AUGraphClose(graph);
    DisposeAUGraph(graph);
}

- (void) dealloc {
    if (_bufferList){
        removeAudioBufferList(_bufferList);
    }
    if (_auGraph) {
        [self releaseAUGraph:_auGraph];
    }
}

@end
