//
//  RemoteIO.h
//  WaveView
//
//  Created by 村上 晋太郎 on 2014/03/04.
//  Copyright (c) 2014年 村上 晋太郎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RemoteIO : NSObject
@property (nonatomic) AudioUnit remoteIOUnit;
@property (nonatomic) AudioBufferList * bufferList;
- (void) prepareAUGraph;
- (void) start;
- (void) restartAUGraph;
- (void) stop;
@end
