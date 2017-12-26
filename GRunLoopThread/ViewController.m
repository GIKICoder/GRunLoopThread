//
//  ViewController.m
//  GRunLoopThread
//
//  Created by GIKI on 2017/12/15.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import "ViewController.h"
#import "GTaskRunThread.h"

@interface GObject:NSObject<ITaskObjectProtocol>
@property (nonatomic, assign) int   seq;
- (void)setTaskSeq:(int)seq;
@end

@implementation GObject
- (void)setTaskSeq:(int)seq
{
    _seq = seq;
}

- (int)getTaskSeq
{
    return _seq;
}
@end

@interface ViewController ()<ITaskStateObserver,ITaskProviderProtocol>
@property (nonatomic, strong) GTaskRunThread * thread;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic, assign) int   index;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.thread = [[GTaskRunThread alloc] init];
    self.thread.taskProvider = self;
    self.thread.stateObserver = self;
    [self.thread start];
}

- (IBAction)btnClick:(id)sender
{
    for (int i = 0; i< 100000; i++) {
        GObject *object = [GObject new];
        [object setTaskSeq:i];
        [self.thread postTask:object];
    }
}
#pragma mark - ITaskProviderProtocol
- (void)invoke:(id<ITaskObjectProtocol>)task
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
         self.textLabel.text = [NSString stringWithFormat:@"%d",[task getTaskSeq]];
    });
   
}

#pragma mark - ITaskStateObserver

-(void)onTaskComplete:(int)nTaskSeq
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
