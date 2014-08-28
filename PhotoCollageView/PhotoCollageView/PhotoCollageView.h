//
//  PhotoCollageView.h
//  PhotoCollageView
//
//  Created by soleaf on 14. 2. 17..
//  Copyright (c) 2014년 soleaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollageView : UIView

@property CGFloat padding;

/* 
    ,로 구분된 Linear URL로 뷰 로딩
    @dataString >> path:width:height,path:width:height,path:width:height 5개
    @Return >> ModelList array 반환(재사용하라고)
*/
- (NSArray*)prepareWithPhotoURLs:(NSString *)dataString;


/*
    modeList로 뷰 로딩
    @modelList >> 이미 모든 frame이 계산된 정보를 가지고 있음
 */
- (BOOL)prepareWithModelList:(NSArray*)modelList;


/*
    바로계산하게
 */
+ (CGFloat) calculatingHeight:(NSString *)dataString;

@end
