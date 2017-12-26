//
//  GTaskRunThread.m
//  GKit
//
//  Created by GIKI on 17/3/7.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import "GTaskRunThread.h"

static void doProcessSource0(void *info)
{
    GTaskRunThread * taskThread = (__bridge  GTaskRunThread*)info;
    [taskThread fired];
}

@interface GTaskRunThread ()
{
    CFRunLoopSourceRef   _runLoopSource;
    CFRunLoopRef   _currentRunLoop;
}
@property (nonatomic, strong) NSMutableArray   *arryOfTask;
@end

@implementation GTaskRunThread

#pragma mark -- override Method

- (void)main
{
    @autoreleasepool {
        
        [self prepare];
        
        CFRunLoopRun();
        
        [self unPrepare];
    }
}

#pragma mark -- public Method

/**
 线程停止run
 */
- (void)stop
{
    if (_currentRunLoop != nil)
        CFRunLoopStop(_currentRunLoop);
}

/**
 向taskRunThread中添加任务
 
 @param task 任务
 */
- (void)postTask:(id<ITaskObjectProtocol>)task
{
    @synchronized (self.arryOfTask) {
        if (self.arryOfTask != nil && task != nil) {
            [self.arryOfTask addObject:task];
        }
    }
    
    CFRunLoopSourceSignal(_runLoopSource);
    CFRunLoopWakeUp(_currentRunLoop);
}

/**
 取消任务
 
 @param nTaskSeq 任务id
 */
- (BOOL)cancelTask:(int)nTaskSeq
{
    BOOL bCancel = NO;
    
    @synchronized (self.arryOfTask) {
        
        NSInteger nTaskCount = [self.arryOfTask count];
        for (NSInteger nIndex = 0; nIndex < nTaskCount; nIndex++) {
            id<ITaskObjectProtocol> task = [self.arryOfTask objectAtIndex:nIndex];
            //todo cancel currentTask
            
            if ([task getTaskSeq] == nTaskSeq) {
                [self.arryOfTask removeObjectAtIndex:nIndex];
                bCancel = YES;
                break;
            }
        }
    }
    return bCancel;
}

/**
 取消所有的任务
 */
- (BOOL)cancelAllTask
{
    BOOL bCancel = NO;
    
    @synchronized (self.arryOfTask) {
        
        [self.arryOfTask removeAllObjects];
        bCancel = YES;
    }
    return bCancel;
}

/**
 开始任务
 */
- (void)fired
{
    BOOL bNoTask = NO;
    id<ITaskObjectProtocol> currentTask = nil ;
    
    while (!bNoTask) {
        
        @autoreleasepool {
            @synchronized (self.arryOfTask) {
                
                if (self.arryOfTask.count > 0) {

                    currentTask = [self.arryOfTask firstObject];
                    [self.arryOfTask removeObjectAtIndex:0];
                }
            }
            
            //Handle event
            if (currentTask != nil) {
                if (self.stateObserver)
                    
                    if ([self.taskProvider respondsToSelector:@selector(invoke)]) {
                        [self.taskProvider invoke];
                    }
                
                if ([self.taskProvider respondsToSelector:@selector(invoke:)]) {
                    [self.taskProvider invoke:currentTask];
                }
                
                if (self.stateObserver)
                    [self.stateObserver onTaskComplete:[currentTask getTaskSeq]];
                currentTask = nil;
            }
            
            @synchronized (self.arryOfTask) {
                
                if (self.arryOfTask.count == 0) {
                    bNoTask = YES;
                }
            }
        }
    }

}

#pragma mark -- private Method

- (void)prepare
{
    _currentRunLoop = CFRunLoopGetCurrent();
    
    [self hookIntoCurrentRunLoop];
}

- (void)unPrepare
{
    [self unHookFromCurrentRunLoop];
    _currentRunLoop = NULL;
}

- (void)createRunLoopSource
{
    CFRunLoopSourceContext context = {0,(__bridge void*)self,NULL,NULL,NULL,NULL,NULL,NULL,NULL,&doProcessSource0};
    _runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
}

- (void)destroyRunLoopSource
{
    CFRelease(_runLoopSource);
    _runLoopSource = nil;
}

- (void)hookIntoCurrentRunLoop
{
    [self createRunLoopSource];
    CFRunLoopAddSource(_currentRunLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

- (void)unHookFromCurrentRunLoop
{
    CFRunLoopRemoveSource(_currentRunLoop, _runLoopSource, kCFRunLoopDefaultMode);
    [self destroyRunLoopSource];
    
}

#pragma mark - getter

- (NSMutableArray *)arryOfTask
{
    if (!_arryOfTask) {
        _arryOfTask = [NSMutableArray array];
    }
    return _arryOfTask;
}

@end
