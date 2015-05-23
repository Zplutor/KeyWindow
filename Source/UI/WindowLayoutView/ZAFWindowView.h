#import <Cocoa/Cocoa.h>


typedef NS_ENUM(NSInteger, ZAFWindowArea) {
    
    ZAFWindowAreaNone,
    ZAFWindowAreaLeftTop,
    ZAFWindowAreaTop,
    ZAFWindowAreaRightTop,
    ZAFWindowAreaRight,
    ZAFWindowAreaRightBottom,
    ZAFWindowAreaBottom,
    ZAFWindowAreaLeftBottom,
    ZAFWindowAreaLeft,
    ZAFWindowAreaCenter,
};


@protocol ZAFWindowViewDelegate <NSObject>

- (void)windowViewWillBeginDraggedInArea:(ZAFWindowArea)area fromMouseLocation:(NSPoint)mouseLocation;
- (void)windowViewIsBeingDraggedToMouseLocation:(NSPoint)mouseLocation;
- (void)windowViewDidEndDragged;

@end


@interface ZAFWindowView : NSView

@property (nonatomic, weak) id<ZAFWindowViewDelegate> delegate;

@property (nonatomic) BOOL enabled;

@end
