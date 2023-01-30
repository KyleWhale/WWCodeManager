//
//  SJLoadFailedControlLayer.m
//  SJCommonCode
//
//  Created by admin on 2018/10/27.
//  Copyright © 2018 admin. All rights reserved.
//

#import "SJLoadFailedControlLayer.h"
#import "SJCommonCodeConfigurations.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJLoadFailedControlLayer ()
@end

@implementation SJLoadFailedControlLayer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _updateSettings];
    return self;
}

- (void)_updateSettings {
    id<SJCommonCodeControlLayerResources> resources = SJCommonCodeConfigurations.shared.resources;
    id<SJCommonCodeLocalizedStrings> strings = SJCommonCodeConfigurations.shared.localizedStrings;
    [self.reloadView.button setTitle:strings.reload forState:UIControlStateNormal];
    self.reloadView.backgroundColor = resources.playFailedButtonBackgroundColor;
    self.promptLabel.text = strings.playbackFailedPrompt;
}
@end
NS_ASSUME_NONNULL_END
