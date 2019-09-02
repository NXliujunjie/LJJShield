//
//  ViewController.m
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//

#import "ViewController.h"
#import "Animal.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Animal *a = [[Animal alloc] init];
    [a run];
    [Animal eat];
}


@end
