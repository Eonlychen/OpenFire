//
//  Music.h
//  OpenFire_OC
//
//  Created by guxiangyun on 2019/3/28.
//  Copyright © 2019 chenran. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Music : NSObject

+ (Music *)shareInstance;

- (void)playBGM;
- (void)bulletShootSound;
- (void)bomb;

@end

NS_ASSUME_NONNULL_END
