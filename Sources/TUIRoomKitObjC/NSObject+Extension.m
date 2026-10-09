// CocoaPods 下 pod 的 umbrella header 会隐式带 Foundation / UIKit，
// SPM 没有这个机制，由 tools/pod2spm/publish_source.py 补上
#import <Foundation/Foundation.h>

//
//  NSObject+Extension.m
//  TUIRoomKit
//
//  Created by adamsfliu on 2026/8/10.
//  Copyright © 2026 Tencent. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (RoomKitExtension)

+ (void)load {
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(roomSwiftLoad)]) {
        [self performSelector:@selector(roomSwiftLoad)];
    }
}

@end
