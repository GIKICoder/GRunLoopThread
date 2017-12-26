//
//  GTaskRunThread.h
//  GKit
//
//  Created by GIKI on 17/3/7.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITaskProtocol.h"

@interface GTaskRunThread : NSThread

/**
 线程停止run
 */
- (void)stop;

/**
 向taskRunThread中添加任务

 @param task 任务
 */
- (void)postTask:(id<ITaskObjectProtocol>)task;

/**
 取消任务

 @param nTaskSeq 任务id
 */
- (BOOL)cancelTask:(int)nTaskSeq;

/**
 取消所有的任务
 */
- (BOOL)cancelAllTask;

/**
 开始任务
 */
- (void)fired;

@property (nonatomic, weak) id<ITaskStateObserver>   stateObserver;

@property (nonatomic, weak) id<ITaskProviderProtocol>  taskProvider;

@end
