//
//  MJMapHeader.h
//  MJAMapDemo
//
//  Created by YXCZ on 2018/1/25.
//  Copyright © 2018年 JingJing_Lin. All rights reserved.
//

#ifndef MJMapHeader_h
#define MJMapHeader_h

///屏幕高
#define SCREEN_HEIGHT CGRectGetHeight([[UIScreen mainScreen] bounds])
///屏幕宽
#define SCREEN_WIDTH CGRectGetWidth([[UIScreen mainScreen] bounds])

/// ios11
#define IOS11 @available(iOS 11.0, *)
/// iPhone X
#define  MJiPhoneX (SCREEN_WIDTH == 375.f && SCREEN_HEIGHT == 812.f ? YES : NO)
#define MJStatusBarHeight (MJiPhoneX ? 44.f : 20.f)
/// navigation bar
#define MJNavBarHeight self.navigationController.navigationBar.frame.size.height
///  Status bar & navigation bar height 64/88
#define MJStatusAndNavHeight (MJStatusBarHeight + MJNavBarHeight)
/// Tabbar height.
#define  MJTabbarHeight (MJiPhoneX ? (49.f+34.f) : 49.f)
/// Tabbar safe bottom margin.
#define  MJTabbarSafeBottomMargin (MJiPhoneX ? 34.f : 0.f)

#ifdef DEBUG
#define MJString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define MJLog(...) printf("%s 第%d行: %s\n\n",[MJString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

#else
#define MJLog(...)
#endif

#endif /* MJMapHeader_h */
