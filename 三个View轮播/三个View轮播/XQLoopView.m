//
//  XQLoopView.m
//  三个View轮播
//
//  Created by 都市蚂蚁 on 2017/1/9.
//  Copyright © 2017年 com.dingqi. All rights reserved.
//

#import "XQLoopView.h"
@interface XQLoopView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *middleImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

/// tap点击事件
@property (nonatomic, strong) UITapGestureRecognizer *tap;
/// scroll timer
@property (nonatomic, strong) NSTimer *scrollTimer;
@end
@implementation XQLoopView
#pragma mark - 重写init方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initUI];
    }
    return self;
}
#pragma mark - 页面初始化处理/销毁处理
- (void)initUI {
    [self setupUI];
    [self placeSubviews];
    [self setScrollViewContentOffsetCenter];
    [self addObservers];
}
- (void)dealloc {
    // 移除通知
    [self removeObservers];
    // 关闭定时器
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}
#pragma mark - setupUI
- (void)setupUI {
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.middleImageView];
    [self.scrollView addSubview:self.rightImageView];
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    
}
- (void)placeSubviews {
    self.scrollView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 30.f, CGRectGetWidth(self.bounds), 20.f);
    
    CGFloat imageWidth = CGRectGetWidth(self.scrollView.bounds);
    CGFloat imageHeight = CGRectGetHeight(self.scrollView.bounds);
    self.leftImageView.frame    = CGRectMake(imageWidth * 0, 0, imageWidth, imageHeight);
    self.middleImageView.frame  = CGRectMake(imageWidth * 1, 0, imageWidth, imageHeight);
    self.rightImageView.frame   = CGRectMake(imageWidth * 2, 0, imageWidth, imageHeight);
    self.scrollView.contentSize = CGSizeMake(imageWidth * 3, 0);
    
}
#pragma mark - kvo
- (void)addObservers {
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObservers {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self caculateCurIndex];
    }
}
#pragma mark - caculate curIndex
- (void)caculateCurIndex {
    if (self.imageURLStrings && self.imageURLStrings.count > 0) {
        CGFloat pointX = self.scrollView.contentOffset.x;
        CGFloat criticalValue = .2f;

        
        if (pointX > 2 * CGRectGetWidth(self.scrollView.bounds) - criticalValue) {
            // right
            self.curIndex = (self.curIndex + 1) % self.imageURLStrings.count;
        } else if (pointX < criticalValue) {
            // scroll left
            self.curIndex = (self.curIndex + self.imageURLStrings.count - 1) % self.imageURLStrings.count;
        }
        
    }
}
#pragma mark - set scrollView contentOffset to center
- (void)setScrollViewContentOffsetCenter {

    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0);
}
#pragma mark - button actions
- (void)imageClicked:(UITapGestureRecognizer *)tap {
    NSLog(@"tap");
    if (self.clickAction) {
        self.clickAction (self.curIndex);
    }
}
#pragma mark - timer action
- (void)scrollTimerDidFired:(NSTimer *)timer {
    // may show two images in one page
    CGFloat criticalValue = .2f;
    if (self.scrollView.contentOffset.x < CGRectGetWidth(self.scrollView.bounds) - criticalValue || self.scrollView.contentOffset.x > CGRectGetWidth(self.scrollView.bounds) + criticalValue) {
        [self setScrollViewContentOffsetCenter];
    }
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.bounds), self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];

}
#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.imageURLStrings.count > 1) {
        [self.scrollTimer setFireDate:[NSDate distantFuture]];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.imageURLStrings.count > 1) {
        [self.scrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.scrollDuration]];
    }
}
#pragma mark - 重写setter方法
- (void)setImageURLStrings:(NSArray *)imageURLStrings {
    if (imageURLStrings) {
        _imageURLStrings = imageURLStrings;
        self.curIndex = 0;
        if (imageURLStrings.count > 1) {
            // auto scroll
            self.pageControl.numberOfPages = imageURLStrings.count;
            self.pageControl.currentPage = 0;
            self.pageControl.hidden = NO;
        } else {
            self.pageControl.hidden = YES;
            [self.leftImageView removeFromSuperview];
            [self.rightImageView removeFromSuperview];
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), 0);
        }
    }
}
- (void)setCurIndex:(NSInteger)curIndex {
    if (_curIndex >= 0) {
        _curIndex = curIndex;
        
        NSInteger imageCount = self.imageURLStrings.count;
        NSInteger leftIndex = (curIndex + imageCount - 1) % imageCount;

        NSInteger rightIndex = (curIndex + 1) % imageCount;
        
        self.leftImageView.image = [UIImage imageNamed:self.imageURLStrings[leftIndex]];
        self.middleImageView.image = [UIImage imageNamed:self.imageURLStrings[curIndex]];
        self.rightImageView.image = [UIImage imageNamed:self.imageURLStrings[rightIndex]];
        [self setScrollViewContentOffsetCenter];
        self.pageControl.currentPage = curIndex;
    }
}
- (void)setScrollDuration:(NSTimeInterval)scrollDuration {
    _scrollDuration = scrollDuration;
    if (scrollDuration > 0.f) {
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:scrollDuration
                                                            target:self
                                                          selector:@selector(scrollTimerDidFired:)
                                                          userInfo:nil
                                                           repeats:YES];
        [self.scrollTimer setFireDate:[NSDate distantPast]];
        

    }
}
#pragma mark - 懒加载视图
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    
    return _scrollView;
}
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    }
    
    return _pageControl;
}
- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_leftImageView addGestureRecognizer:self.tap];
        _leftImageView.userInteractionEnabled = YES;
    }
    
    return _leftImageView;
}
- (UIImageView *)middleImageView {
    if (!_middleImageView) {
        _middleImageView = [[UIImageView alloc] init];
        _middleImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_middleImageView addGestureRecognizer:self.tap];
        _middleImageView.userInteractionEnabled = YES;
    }
    
    return _middleImageView;
}
- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
        //_rightImageView.backgroundColor = [UIColor greenColor];
    }
    
    return _rightImageView;
}
- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked:)];
    }
    return _tap;
}



@end
