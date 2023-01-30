//
//  SJClipsCommonViewLayer.m
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SJClipsCommonViewLayer.h"
#import <UIKit/UIKit.h>

@implementation SJClipsCommonViewLayer
- (void)layoutSublayers {
    [super layoutSublayers];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8].CGColor;
    self.cornerRadius = self.bounds.size.height * 0.5;
}
@end
