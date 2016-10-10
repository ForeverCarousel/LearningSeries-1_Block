//
//  ViewController.h
//  BlockMemeorySample
//
//  Created by Carouesl on 16/9/27.
//  Copyright © 2016年 Youku Tudou Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^callBackBlock) (NSInteger index);


@interface ViewController : UIViewController


@property (nonatomic, copy) callBackBlock callBack;

@end

