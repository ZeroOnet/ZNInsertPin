//
//  ViewController.m
//  ZNInsertPin
//
//  Created by FunctionMaker on 2017/4/13.
//  Copyright © 2017年 FunctionMaker. All rights reserved.
//

#import "ViewController.h"
#import "ZNInsertPinGameView.h"

@interface ViewController ()

@property (strong, nonatomic) ZNInsertPinGameView *insertPinView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.insertPinView];
}

- (ZNInsertPinGameView *)insertPinView {
    if (!_insertPinView) {
        _insertPinView = [[ZNInsertPinGameView alloc] initWithFrame:self.view.bounds];
        _insertPinView.backgroundColor = [UIColor grayColor];
    }
    
    return _insertPinView;
}

@end
