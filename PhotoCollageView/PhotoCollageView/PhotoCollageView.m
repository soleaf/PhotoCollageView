//
//  PhotoCollageView.m
//  PhotoCollageView
//
//  Created by soleaf on 14. 2. 17..
//  Copyright (c) 2014년 soleaf. All rights reserved.
//

#import "PhotoCollageView.h"

#import "PhotoCollageItem.h"
#import "UIView+frame.h"
#import "UIImageView+WebCache.h"

enum LayoutRatioType {
    LayoutRatioTypeSingle = 0,
    LayoutRatioType2Vertical,
    LayoutRatioType2RegularSquare,
    LayoutRatioType2Horizontal,
    LayoutRatioType3FirstVertical,
    LayoutRatioType3FirstHorizontal,
    LayoutRatioType4FirstVertical,
    LayoutRatioType4FirstHorizontal,
    LayoutRatioType5FirstVertical,
    LayoutRatioType5FirstHorizontal,
    };
typedef NSInteger LayoutRatioType;

@interface PhotoCollageView ()
{
    NSMutableArray *subViewList;
}
@end

@implementation PhotoCollageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - Frist Calc And Draw

- (NSArray*)prepareWithPhotoURLs:(NSString *)dataString
{
    
    // URL 파싱 & Model생성
    NSArray *modelList = [PhotoCollageView parseURLString:dataString];
    
    // 레이아웃 결정
    LayoutRatioType layout = [PhotoCollageView chooseLayout:modelList];
    NSArray *layoutRatio = [PhotoCollageView calcLayoutRatios:layout];
    
    // 레이아웃에 따라서 사이즈 계산
    [self calcViewSizes:layoutRatio andModelList:modelList];
    NSLog(@"layout:%d",layout);
    
    // 레이아웃에 따라서 좌표 계산
    [self putOriginWithLayout:layout toNoCalcedModeList:modelList];
    
    // 그리기
    [self makeImageViews:modelList];
    
    // 이미지 로딩
    [self fireImageLoadingCascade:modelList];
    
    // Height fix
    self.sizeHeight = [PhotoCollageView calculatingViewHeightFrom:modelList withPadding:self.padding andWith:self.sizeWidth];
    
    return modelList;
}


/*
 Layout에 따라서 그릴 SubView size 계산
 (2014. 02. 17 15:07)
 */
- (void) calcViewSizes:(NSArray*) layoutRatio andModelList:(NSArray*)modelList
{
    for (NSInteger i=0; i < modelList.count; i++) {
        
        PhotoCollageItem *item = [modelList objectAtIndex:i];
        NSArray *layoutSet = [layoutRatio objectAtIndex:i];
        
        NSString *expStrW = [layoutSet objectAtIndex:0];
        NSString *expStrH = [layoutSet objectAtIndex:1];
        
        expStrW = [expStrW stringByReplacingOccurrencesOfString:@"w"
                                                     withString:[NSString stringWithFormat:@"%f",self.sizeWidth]];
        expStrW = [expStrW stringByReplacingOccurrencesOfString:@"p"
                                                     withString:[NSString stringWithFormat:@"%f",self.padding]];
        expStrH = [expStrH stringByReplacingOccurrencesOfString:@"w"
                                                     withString:[NSString stringWithFormat:@"%f",self.sizeWidth]];
        expStrH = [expStrH stringByReplacingOccurrencesOfString:@"p"
                                                     withString:[NSString stringWithFormat:@"%f",self.padding]];
        
        NSExpression *expression = [NSExpression expressionWithFormat:expStrW];
        item.width  = [[expression expressionValueWithObject:nil context:nil] floatValue];
        
        expression = [NSExpression expressionWithFormat:expStrH];
        item.height = [[expression expressionValueWithObject:nil context:nil] floatValue];
        
    }
}

/*
 Size에따라서 View생성 및 배치
 (2014. 02. 17 16:00)
 */
- (void) putOriginWithLayout:(LayoutRatioType)layout toNoCalcedModeList:(NSArray*)modelList
{
    NSInteger testKey = 0;
    for (PhotoCollageItem *item in modelList) {
        
        testKey++;
        
        // 위치결정
        CGPoint orign = (modelList.count == 5 ?
                         [self calcViewOriginFor5items:testKey andLayout:layout] :
                         [self calcViewOrigin:item]);
        item.x = orign.x;
        item.y = orign.y;
    
        [self MakeImageView:modelList at:testKey-1];
        
        NSLog(@"orign %f.%f",orign.x, orign.y);
        
    }
}

/*
 5개 아이템은 좌표를 직접 계산하도록함
 (2014. 02. 18 10:01)
 */
- (CGPoint) calcViewOriginFor5items:(NSInteger)idx andLayout:(LayoutRatioType)layout
{
    NSString *expX = nil;
    NSString *expY = nil;
    
    if (layout == LayoutRatioType5FirstVertical) {
        
        switch (idx) {
            case 1:
                expX = @"0";
                expY = @"0";
                break;
            case 2:
                expX = @"(w-p)/2+p";
                expY = @"0";
                break;
            case 3:
                expX = @"(w-p)/2+p";
                expY = @"(w-2*p)/3+p";
                break;
            case 4:
                expX = @"0";
                expY = @"(w-p)/2+p";
                break;
            case 5:
                expX = @"(w-p)/2+p";
                expY = @"(w-2*p)/3*2+2*p";
                break;
            default:
                break;
        }
        
    }
    else
    {
        //LayoutRatioType5FirstHorizontal
        
        switch (idx) {
            case 1:
                expX = @"0";
                expY = @"0";
                break;
            case 2:
                expX = @"(w-p)/2+p";
                expY = @"0";
                break;
            case 3:
                expX = @"0";
                expY = @"(w-p)/2+p";
                break;
            case 4:
                expX = @"(w-2*p)/3*1+1*p";
                expY = @"(w-p)/2+p";
                break;
            case 5:
                expX = @"(w-2*p)/3*2+2*p";
                expY = @"(w-p)/2+p";
                break;
            default:
                break;
        }
        
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    expX = [expX stringByReplacingOccurrencesOfString:@"p"
                                           withString:[NSString stringWithFormat:@"%f",self.padding]];
    expX = [expX stringByReplacingOccurrencesOfString:@"w"
                                           withString:[NSString stringWithFormat:@"%f",self.sizeWidth]];
    expY = [expY stringByReplacingOccurrencesOfString:@"p"
                                           withString:[NSString stringWithFormat:@"%f",self.padding]];
    expY = [expY stringByReplacingOccurrencesOfString:@"w"
                                           withString:[NSString stringWithFormat:@"%f",self.sizeWidth]];
    
    
    NSExpression *expression = [NSExpression expressionWithFormat:expX];
    x  = [[expression expressionValueWithObject:nil context:nil] floatValue];
    
    expression = [NSExpression expressionWithFormat:expY];
    y = [[expression expressionValueWithObject:nil context:nil] floatValue];
    
    NSLog(@"expX:%@ = %f",expX, x);
    NSLog(@"expY:%@ = %f",expY, y);
    
    return CGPointMake(x, y);
}


- (CGPoint) calcViewOrigin:(PhotoCollageItem*)item
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGPoint plusPoint = CGPointMake(0, 0);
    
    do {
        if (plusPoint.x > 0)
            x = plusPoint.x + self.padding;
        if (plusPoint.y > 0)
            y = plusPoint.y + self.padding;
        
        plusPoint = [self isAlreadInUIViewAtlocation:CGPointMake(x, y)];
        
    } while (plusPoint.x > 0 || plusPoint.y > 0);
    
    
    return CGPointMake(x, y);
}

/*
 X좌표가 subView의 영역에 있으면 영역을 피할 수 있는 최대값 반환
 (2014. 02. 17 16:23)
 */
- (CGPoint) isAlreadInUIViewAtlocation:(CGPoint)point
{
    CGFloat plusX = 0;
    CGFloat plusY = 0;
    for (UIView *view in self.subviews) {
        
        if (view.originX + view.sizeWidth >= point.x)
        {
            plusX = view.originX + view.sizeWidth;
            
            // 현재줄을 넘어서 x를 추가하는지
            if (plusX < self.sizeWidth) {
                return CGPointMake(plusX, plusY);
            }
            else
            {
                // 현재 줄을 넘어서면 y값이 조정하되록하고, x는 0이 되도록 유도하기
                plusX = -self.sizeWidth;
            }
            
            if (view.originY + view.sizeHeight >= point.y)
            {
                plusY = view.originY + view.sizeHeight;
                return CGPointMake(plusX, plusY);
            }
        }
        
        // 세로를 넘어가는지 검사하자
        if (point.y > self.sizeHeight)
        {
            return CGPointMake(plusX, -self.sizeHeight);
            
        }
    }
    
    return CGPointMake(plusX, plusY);
}


#pragma mark - Draw
/*
 이미지 뷰 생성
 (2014. 02. 18 11:47)
 */
- (void) makeImageViews:(NSArray*)modelList;
{
    subViewList = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < modelList.count; i ++)
    {
        [self MakeImageView:modelList at:i];
    }
}

- (void)MakeImageView:(NSArray*)modelList at:(NSInteger)idx
{
    PhotoCollageItem *item = [modelList objectAtIndex:idx];
    
    UIImageView *IV = [[UIImageView alloc] initWithFrame:
                       CGRectMake(item.x, item.y, item.width, item.height)];
    IV.backgroundColor = [UIColor colorWithRed:0.933333 green:0.933333 blue:0.933333 alpha:1.000000];
    IV.tag = idx;
    IV.contentMode = UIViewContentModeScaleAspectFill;
    IV.clipsToBounds = YES;
    
    // 싱글이미지에서만 이미지가 늘어날수있도록 뷰크기에 맞춰서
    if (modelList.count == 1)
        IV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:IV];
    [subViewList addObject:IV];
}

/*
 이미지 로딩 cascade 시작
 (2014. 02. 18 11:48)
 */
- (void) fireImageLoadingCascade:(NSArray*)modelList
{
    
    [self imageLoadCascade:modelList at:0];
    
}

- (void) imageLoadCascade:(NSArray*)modelList at:(NSInteger)num
{
    if (num >= modelList.count) return;
    PhotoCollageItem *item = [modelList objectAtIndex:num];
    UIImageView *IV = (UIImageView*) [subViewList objectAtIndex:num];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",item.path]];
    
    NSLog(@"url:%@",url);
    
    [IV setImageWithURL:url placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        [self imageLoadCascade:modelList at:num+1];
        
    }];
}




#pragma mark - Static


/*
 Linear string data 파싱후 모델객체로 반환
 (2014. 02. 17 14:53)
 */
+ (NSMutableArray*)parseURLString:(NSString*)urlString
{
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSString *segment in [urlString componentsSeparatedByString:@","]) {
        
        NSArray *info = [segment componentsSeparatedByString:@"|"];
        PhotoCollageItem *item = [[PhotoCollageItem alloc] init];
        item.path = [info objectAtIndex:0];
        item.width = [[info objectAtIndex:1] floatValue];
        item.height = [[info objectAtIndex:2] floatValue];
        item.originWidth = item.width;
        item.originHeight = item.height;
        
        [list addObject:item];
    }
    
    return list;
}

/*
 모델을 가지고 레이아웃 결정
 (2014. 02. 17 14:27)
 */
+ (LayoutRatioType) chooseLayout:(NSArray*)modelList
{
    PhotoCollageItem *firstItem = [modelList objectAtIndex:0];
    NSInteger count = modelList.count;
    
    LayoutRatioType type = LayoutRatioTypeSingle;
    
    if (count == 1) type = LayoutRatioTypeSingle;
    
    else if (count == 2)
    {
        PhotoCollageItem *secondItem = [modelList objectAtIndex:1];
        
        if (firstItem.width < firstItem.height &&
            secondItem.width < secondItem.height) type = LayoutRatioType2Vertical;
        else if (firstItem.width > firstItem.height &&
                 secondItem.width > secondItem.height) type = LayoutRatioType2Horizontal;
        else
            type = LayoutRatioType2RegularSquare;
    }
    
    else if (count == 3)
    {
        if (firstItem.width < firstItem.height)
            type = LayoutRatioType3FirstVertical;
        else
            type = LayoutRatioType3FirstHorizontal;
    }
    
    else if (count == 4)
    {
        if (firstItem.width < firstItem.height)
            type = LayoutRatioType4FirstVertical;
        else
            type = LayoutRatioType4FirstHorizontal;
    }
    
    else if (count == 5)
    {
        if (firstItem.width < firstItem.height)
            type = LayoutRatioType5FirstVertical;
        else
            type = LayoutRatioType5FirstHorizontal;
    }
    
    return type;
}


/*
 Layout Type에 따라 width, height 비율을 반환
 (2014. 02. 17 12:24)
 */
+ (NSArray*) calcLayoutRatios:(LayoutRatioType)layout
{
    NSArray *ratios = nil;
    switch (layout) {
        case LayoutRatioTypeSingle:
            // Single 레이아웃은 의미없음
            ratios = @[@[@"w", @"w"]];
            break;
            
        case LayoutRatioType2Vertical:
            ratios = @[@[@"(w-p)/2", @"w"],
                       @[@"(w-p)/2", @"w"],
                       ];
            break;
        case LayoutRatioType2Horizontal:
            ratios = @[@[@"w", @"(w-p)/2"],
                       @[@"w", @"(w-p)/2"]
                       ];
            break;
        case LayoutRatioType2RegularSquare:
            ratios = @[@[@"(w-p)/2", @"(w-p)/2"],
                       @[@"(w-p)/2", @"(w-p)/2"]
                       ];
            break;
        
        case LayoutRatioType3FirstVertical:
            ratios = @[@[@"(w-p)/2", @"w"],
                       @[@"(w-p)/2", @"(w-p)/2"],
                       @[@"(w-p)/2", @"(w-p)/2"]
                       ];
            break;
        case LayoutRatioType3FirstHorizontal:
            ratios = @[@[@"w", @"(w-p)/2"],
                       @[@"(w-p)/2", @"(w-p)/2"],
                       @[@"(w-p)/2", @"(w-p)/2"]
                       ];
            break;
        
        case LayoutRatioType4FirstVertical:
            ratios = @[@[@"(w-p) * 2/3", @"w"],
                       @[@"(w-p)/3", @"(w-2*p)/3"],
                       @[@"(w-p)/3", @"(w-2*p)/3"],
                       @[@"(w-p)/3", @"(w-2*p)/3"]
                       ];
            break;
        case LayoutRatioType4FirstHorizontal:
            ratios = @[@[@"w", @"(w-p) *2/3"],
                       @[@"(w-2*p)/3", @"(w-p)/3"],
                       @[@"(w-2*p)/3", @"(w-p)/3"],
                       @[@"(w-2*p)/3", @"(w-p)/3"]
                       ];
            break;
            
        
        case LayoutRatioType5FirstVertical:
            ratios = @[@[@"(w-p)/2", @"(w-p)/2"],
                       @[@"(w-p)/2", @"(w-2*p)/3"],
                       @[@"(w-p)/2", @"(w-2*p)/3"],
                       @[@"(w-p)/2", @"(w-p)/2"],
                       @[@"(w-p)/2", @"(w-2*p)/3"]
                       ];
            break;
        case LayoutRatioType5FirstHorizontal:
            ratios = @[@[@"(w-p)/2", @"(w-p)/2"],
                       @[@"(w-p)/2", @"(w-p)/2"],
                       @[@"(w-2*p)/3", @"(w-2*p)/3"],
                       @[@"(w-2*p)/3", @"(w-2*p)/3"],
                       @[@"(w-2*p)/3", @"(w-2*p)/3"]
                       ];
            break;

            
        default:
            break;
    }
    
    return ratios;
}

+ (CGFloat) calcHeightFromLayout:(LayoutRatioType)layout withPadding:(CGFloat)padding andWidth:(CGFloat)width
{
    NSString *exp = @"";
    switch (layout) {
        case LayoutRatioTypeSingle:
            break;
            
        case LayoutRatioType2Vertical:
            exp = @"w";
            break;
        case LayoutRatioType2Horizontal:
            exp = @"w";
            break;
        case LayoutRatioType2RegularSquare:
            exp = @"w/2";
            break;
        case LayoutRatioType3FirstVertical:
            exp = @"w";
            break;
        case LayoutRatioType3FirstHorizontal:
            exp = @"w";
            break;
            
        case LayoutRatioType4FirstVertical:
            exp = @"w";
            break;
        case LayoutRatioType4FirstHorizontal:
            exp = @"w";
            break;
            
        case LayoutRatioType5FirstVertical:
            exp = @"w";
            break;
        case LayoutRatioType5FirstHorizontal:
            exp = @"(w-p)/2 + (w-2*p)/3";
            break;
            
        default:
            break;
    }
    
    exp = [exp stringByReplacingOccurrencesOfString:@"p"
                                           withString:[NSString stringWithFormat:@"%f",padding]];
    exp = [exp stringByReplacingOccurrencesOfString:@"w"
                                           withString:[NSString stringWithFormat:@"%f",width]];
    
    NSExpression *expression = [NSExpression expressionWithFormat:exp];
    CGFloat height = [[expression expressionValueWithObject:nil context:nil] floatValue];;
    
    return height;
}

+ (CGFloat) calculatingViewHeightFrom:(NSArray*)modelList withPadding:(CGFloat)padding andWith:(CGFloat)width
{
    
    // 레이아웃 결정
    LayoutRatioType layout = [PhotoCollageView chooseLayout:modelList];
    if (layout == LayoutRatioTypeSingle)
    {
        // 직접 계산
        PhotoCollageItem *item = [modelList objectAtIndex:0];
        return (width * item.originWidth / item.originHeight);
    }
    else
    {
        return [self calcHeightFromLayout:layout withPadding:padding andWidth:width];
    }
}

+ (CGFloat) calculatingViewHeight:(NSString *)dataString withPadding:(CGFloat)padding andWith:(CGFloat)width
{
    
    // URL 파싱 & Model생성
    NSArray *modelList = [PhotoCollageView parseURLString:dataString];
    
    // 레이아웃 결정
    LayoutRatioType layout = [PhotoCollageView chooseLayout:modelList];
    if (layout == LayoutRatioTypeSingle)
    {
        // 직접 계산
        PhotoCollageItem *item = [modelList objectAtIndex:0];
        return (width * item.originWidth / item.originHeight);
    }
    else
    {
        return [self calcHeightFromLayout:layout withPadding:padding andWidth:width];
    }
}

@end
