//
//  ITaskProtocol.h
//  GKit
//
//  Created by GIKI on 17/3/7.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ITaskObjectProtocol <NSObject>

- (void)setTaskObject:(__kindof id)taskObject;

- (__kindof id)getTaskObject;


- (void)setTaskSeq:(int)seq;

- (int)getTaskSeq;

@end

@protocol ITaskProviderProtocol <NSObject>

@optional

- (void)invoke;
- (void)invoke:(id<ITaskObjectProtocol>)task;

@end

@protocol ITaskStateObserver <NSObject>

@optional

-(void)onTaskComplete:(int)nTaskSeq;
-(void)onTaskBeforeStart:(int)nTaskSeq;

@end
