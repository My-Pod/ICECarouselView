//
//  ICECarouselView.h
//  Pods
//
//  Created by WLY on 16/6/14.
//
//
/**
 *  简单的轮播图实现
 *  
 *
 */


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^DidSelectedBlock) (NSInteger index);

@interface ICECarouselView : UIView

- (nullable instancetype)init __attribute__((unavailable("方法不可用,请用 - initWithFrame: ")));

/**
 *  通过图片数组创建轮播图, 当设置的图片为URL时 可以通过这个方法来设置占位图片
 *
 *  @return 返回
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame
                     withImgs:(nonnull NSArray <UIImage*> *)imgs ;



/**
 *  imgs 可以是 UIImage 也可以是 URL
 */
- (void)setImages:(NSArray *)imgs;

///imgs 可以是 UIImage 也可以是 URL
- (void)setImages:(NSArray *)imgs withPlaceholder:(UIImage *)image;


/**
 *  自动滚动时间间隔
 */
- (void)setPartTime:(float)partTime;

/**
 *  如果使用pageController 可用于设置原点的颜色
 *
 *  @param tinColor  默认的 tincolor
 */
- (void)setPageControlTinColor:(nonnull UIColor *)tinColor;


/**
 *  如果使用pageController 可用于设置原点的颜色
 *
 *  @param tinColor 当前的 tincolor
 */
- (void)setPageControlCurretnTinColor:(nonnull UIColor *)tinColor;


/**
 *  选中某一视图的回调
 */
- (void)didSelectedCompletion:(nullable DidSelectedBlock)completion;

@end




@interface ICECarouselCCell : UICollectionViewCell

@property (nonatomic, strong)  UIImageView * _Nonnull  imageView;

@end




@interface ICECarouselView (DownLoadImage)

- (void)setImageView:(UIImageView *)imageView
        withImageURL:(NSString *)imageURL
withPlaceholderImage:(nullable UIImage *)image;

@end


NS_ASSUME_NONNULL_END

