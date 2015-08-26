//
//  AudioBufferList.m
//  WaveView
//
//  Created by 村上 晋太郎 on 2014/03/06.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#import "AudioBufferList.h"

AudioBufferList * allocateAudioBufferList(UInt32 numChannels, UInt32 size)
{
  AudioBufferList *list;
  UInt32 i;
  
  list = (AudioBufferList*)calloc(1, sizeof(AudioBufferList) + numChannels * sizeof(AudioBuffer));
  if (list == NULL) return NULL;
  
  list->mNumberBuffers = numChannels;
  
  for(i = 0; i < numChannels; ++i) {
    list->mBuffers[i].mNumberChannels = 1;
    list->mBuffers[i].mDataByteSize = size;
    list->mBuffers[i].mData = malloc(size);
    if(list->mBuffers[i].mData == NULL) {
      removeAudioBufferList(list);
      return NULL;
    }
  }
  
  return list;
}

void removeAudioBufferList(AudioBufferList * list)
{
  UInt32 i;
  
  if(list) {
    for(i = 0; i < list->mNumberBuffers; i++) {
      if (list->mBuffers[i].mData) free(list->mBuffers[i].mData);
    }
    free(list);
  }
}
