//
//  Person.h
//  BlockMemeorySample
//
//  Created by Carouesl on 2016/10/1.
//  Copyright © 2016年 Youku Tudou Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^speakBlock)(NSString* contents);

@interface Person : NSObject

@property (nonatomic, copy) speakBlock speakBlock;
@end
