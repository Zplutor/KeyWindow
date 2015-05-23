#import <Cocoa/Cocoa.h>


@protocol ZAFWindowLayoutViewDelegate <NSObject>

- (void)windowLayoutDidClear;

- (void)windowLayoutDidChangeToXPercent:(double)xPercent
                               yPercent:(double)yPercent
                           widthPercent:(double)widthPercent
                          heightPercent:(double)heightPercent;

@end


/**
 用来显示和修改窗口在桌面上的布局的视图。
 
 该视图使用百分比来表示窗口的X坐标、Y坐标、宽度以及高度。坐标系的坐标原点在桌面左上角，
 X坐标从左到右递增，Y坐标从上到下递增。
 */
@interface ZAFWindowLayoutView : NSView

@property (nonatomic, weak) id<ZAFWindowLayoutViewDelegate> delegate;

/**
 获取窗口布局是否被清除的指示值。
 
 当窗口布局被清除时，不会显示窗口，窗口的四个属性都是0，单独设置各个属性不会生效。
 该属性默认值是YES。
 */
@property (nonatomic, readonly) BOOL isCleared;

@property (nonatomic) double xPercent;
@property (nonatomic) double yPercent;
@property (nonatomic) double widthPercent;
@property (nonatomic) double heightPercent;

/**
 获取或设置当前视图是否响应事件的指示值。
 
 该值为NO时，不能修改窗口布局。
 */
@property (nonatomic) BOOL enabled;

/**
 清除窗口布局。
 */
- (void)clear;

/**
 改变窗口布局。
 */
- (void)changeWithXPercent:(double)xPercent
                  yPercent:(double)yPercent
              widthPercent:(double)widthPercent
             heightPercent:(double)heightPercent;

@end
