//
//  Person.m
//  BlockMemeorySample
//
//  Created by Carouesl on 2016/10/1.
//  Copyright © 2016年 Youku Tudou Inc. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(void)dealloc
{
    NSLog(@"%@ is dealloced",NSStringFromClass([self class]));
}

@end
