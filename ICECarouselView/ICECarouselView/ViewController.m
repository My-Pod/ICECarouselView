//
//  ViewController.m
//  ICECarouselView
//
//  Created by WLY on 16/9/19.
//  Copyright © 2016年 ICE. All rights reserved.
//

#import "ViewController.h"
#import "ICECarouselView.h"

@interface ViewController ()

@end



static  NSString *imgURL1 = @"http://101.200.0.204:8089/images/banner1.jpg";
static  NSString *imgURL2 = @"http://101.200.0.204:8089/images/banner2.jpg";
static  NSString *imgURL3 = @"http://101.200.0.204:8089/images/banner3.jpg";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor redColor];
    NSArray *array = @[imgURL1, imgURL2,imgURL3];
    
    
    ICECarouselView *carouselView = [[ICECarouselView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 240) ];
    [carouselView setPageControlCurretnTinColor:[UIColor blueColor]];
    [carouselView setImages:array withPlaceholder:nil];
    
    [self.view addSubview:carouselView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
