//
//  ICECarouselView.m
//  Pods
//
//  Created by WLY on 16/6/14.
//
//
/**
 
 */

#import "ICECarouselView.h"
#import <CommonCrypto/CommonDigest.h>


const static float ICEPageControl_H = 40;
static UIImageView *imgVTool = nil;


@interface ICECarouselView ()<UICollectionViewDataSource,UICollectionViewDelegate, UIScrollViewDelegate,NSURLSessionDelegate>{
    
    float             _partTime; //轮播图时间间隔
    NSArray   *_datasource; //数据源
    NSTimer          *_timer; //定时器
    NSInteger         _index; //当前展示的图片下标
    UIPageControl    *_pageControl;
    UIImage          *_placeholderImg;//占位图片
    UICollectionView *_collectionView;
    UIColor          *_pageTinColor; //用于设置 pageTinColor
    UIColor          *_pageCurretnTinColor; //用于设置 pageCurrentTinColor
    DidSelectedBlock  _completionBlock; //选中回调
}



@end

@implementation ICECarouselView


#pragma mark - life cycle

- (instancetype)init{
    
    self = [super init];
    if (self) {
        [self p_configInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self p_configInit];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame withImgs:(NSArray<UIImage *> *)imgs{
    
    self = [self initWithFrame:frame];
    if (self) {
        [self p_setImgs:imgs];
    }
    return self;
}

- (void)dealloc
{

    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    //销毁dealloc
    _completionBlock = nil;
    
}

- (void)didMoveToSuperview{
    
    [super didMoveToSuperview];
    [self p_startCarousel];
}

#pragma mark -  config init

/**
 *  初始化数据
 */
- (void)p_configInit{
    
    self.autoresizesSubviews = NO;
    _datasource = [NSMutableArray array];
    _partTime = 2.50f;
    _index = 0;
    _timer = nil;
    _pageCurretnTinColor = [UIColor redColor];
    _pageTinColor = [UIColor whiteColor];
}



#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 3;
}
//默认 1, 计时器 + 1  执行滚动到2
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    ICECarouselCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    NSInteger spacing = indexPath.row - 1;
    NSInteger row = _index + spacing;
    
    if (row == _datasource.count) {
        row = 0;
    }
    if (row == -1) {
        row = _datasource.count - 1;
    }
    
    id obj = _datasource[row];
    if ([obj isKindOfClass:[UIImage class]]) {
        cell.imageView.image = _datasource[row];
    }else if ([obj isKindOfClass:[NSString class]]){
        
        [self setImageView:cell.imageView withImageURL:obj withPlaceholderImage:_placeholderImg ];
    }
    
    
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == 2 || indexPath.row == 0) {
        if (_index < 0) {
            [self p_setIndex:_datasource.count - 1];
        }
        
        if (_index > _datasource.count - 1) {
            [self p_setIndex:0];;
        }
        
        return;
    }
    
    
    NSIndexPath *visiableIndexPath = collectionView.indexPathsForVisibleItems.lastObject;
    
    if (visiableIndexPath.row == 2) {
        [self p_setIndex:_index + 1];
    }
    if (visiableIndexPath.row == 0) {
        [self p_setIndex:_index - 1];
    }
    
    [self p_setDefaultPosition];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_completionBlock) {
        _completionBlock(_index);
    }
}

#pragma mark - scrlllerView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self p_stopAutoCarousel];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self p_startCarousel];
}


#pragma mark  action
/**
 *  定时器操作
 */
- (void)p_handleCarouselAction:(NSTimer *)sender{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
}

/**
 *  设置默认位置, (默认 collectionView 显示第2个单元格)
 */
- (void)p_setDefaultPosition{
    //默认位置
    _collectionView.contentOffset = CGPointMake(self.bounds.size.width, 0);
}


#pragma mark - setter && getter

- (UICollectionView *)collectionView{
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = self.bounds.size;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        if([UIDevice currentDevice].systemVersion.floatValue >= 10.0){
        _collectionView.prefetchingEnabled = false;//适配 iOS 10 , 不使用预加载,置为 false,仍使用 10 之前的加载模式
        }
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[ICECarouselCCell class] forCellWithReuseIdentifier:@"CELL"];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}


- (void)p_configPageCongtrol{
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - ICEPageControl_H, CGRectGetWidth(self.bounds), ICEPageControl_H)];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = _pageTinColor;
        _pageControl.currentPageIndicatorTintColor = _pageCurretnTinColor;
        [self addSubview:_pageControl];
    }
    _pageControl.numberOfPages = _datasource.count;

}

/**
 *  返回当前视图高度
 */
- (CGFloat)width{
    return CGRectGetWidth(self.bounds);
}
/**
 *  返回当前视图高度
 */
- (CGFloat)heigth{
    return CGRectGetHeight(self.bounds);
}



- (void)setImages:(NSArray *)imgs{
    [self p_setImgs:imgs];
}

- (void)setImages:(NSArray *)imgs withPlaceholder:(UIImage *)image{
    _placeholderImg = image;
    [self p_setImgs:imgs];
}

- (void)setPartTime:(float)partTime{
    _partTime = partTime;
    if (_timer) {
        [self p_startCarousel];
    }
}


- (void)setPageControlCurretnTinColor:(UIColor *)tinColor{
    _pageCurretnTinColor = tinColor;
    if (_pageControl) {
        _pageControl.currentPageIndicatorTintColor = _pageCurretnTinColor;
    }
    
}

- (void)setPageControlTinColor:(UIColor *)tinColor{
    _pageTinColor = tinColor;
    if (_pageControl) {
        _pageControl.pageIndicatorTintColor = _pageTinColor;
    }
}


- (void)didSelectedCompletion:(DidSelectedBlock)completion{
    _completionBlock = [completion copy];
}

- (void)p_setImgs:(NSArray *)imgs{
    
    _datasource = [imgs copy];
    if (_datasource.count < 1) return;
    
    //当图片数大于1才可以实现滚动, 并添加计时器
    [self p_startCarousel];
    _pageControl.currentPage = 0;
    [self p_setDefaultPosition];
    
}


-(void)p_setIndex:(NSInteger)index{
    
    _index = index;
    if (_pageControl) {
        _pageControl.currentPage = index;
    }

}


#pragma mark - carouse progress

/**
 *  开始滚动:  添加计时器, 并设置轮播图, 及相关配置
 */
- (void)p_startCarousel{
    
    [self.collectionView reloadData];
    _collectionView.scrollEnabled = YES;
    
    //图片个数为1,不滚动
    if (_datasource.count == 1) {
        _collectionView.scrollEnabled = NO;
        [_pageControl removeFromSuperview];
        _pageControl = nil;
        [_timer invalidate];
        _timer = nil;
        
        return;
    }
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    //添加计时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:_partTime target:self selector:@selector(p_handleCarouselAction:) userInfo:nil repeats:YES];
    
    //配置辅助视图
    [self p_configPageCongtrol];
    
    
}

/**
 *  停止自动滚动
 */
- (void)p_stopAutoCarousel{
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
}


#pragma mark - private methods





@end




@implementation ICECarouselCCell

- (UIImageView *)imageView{
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end




@implementation ICECarouselView (DownLoadImage)

#pragma mark -
#pragma mark - NSURLSessionDelegate


#pragma mark - public methods
- (void)setImageView:(UIImageView *)imageView withImageURL:(NSString *)imageURL withPlaceholderImage:(UIImage *)image{
    if (![imageURL hasPrefix:@"http"])  return;
    
    
    
    NSString *filePath = [self p_getImageFilePath:imageURL];
    BOOL hasLoad = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil];
    if (hasLoad) {
        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
        return;
    }
    //设置默认图片
    if (image) {
        imageView.image = image;
    }
    //下载
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:imageURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) return ;
            
            [data writeToFile:filePath atomically:YES];
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });
        }];
        [task resume];
        
    });

}





#pragma mark - private methods


///获取图片文件路径
- (NSString *)p_getImageFilePath:(NSString *)imageURL{
    NSString *imageFileCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"carouselImage"];
    [self p_checkDirectory:imageFileCachePath];
    
    NSString *imageFileName = [self p_md5StringFromString:imageURL];
    NSString * imagePath = [imageFileCachePath stringByAppendingPathComponent:imageFileName];
    return imagePath;
}

///创建文件夹
- (void)p_checkDirectory:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                       attributes:nil error:nil];
        }
    }
}

- (NSString *)p_md5StringFromString:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}


@end
