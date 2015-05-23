#import "ZAFWindowLayoutView.h"
#import <AppKit/AppKit.h>
#import "ZAFAlignmentLinesView.h"
#import "ZAFWindowView.h"


typedef NS_ENUM(NSInteger, ZAFFramePropertyChangeMethod) {
    
    ZAFFramePropertyNotChange,
    ZAFFramePropertyChangeAlongWithMouse,
    ZAFFramePropertyChangeOppositeToMouse,
};


typedef NS_OPTIONS(NSInteger, ZAFStickPosition) {
    
    ZAFStickPositionFirstEdge = 1 << 0,
    ZAFStickPositionSecondEdge = 1 << 1,
    ZAFStickPositionCenter = 1 << 2,
};


static void AdjustFrameDimension(CGFloat bound,
                                 ZAFFramePropertyChangeMethod originChangeMethod,
                                 ZAFFramePropertyChangeMethod sizeChangeMethod,
                                 CGFloat* origin,
                                 CGFloat* size);

static ZAFStickPosition StickFrameDimension(CGFloat bound,
                                            ZAFFramePropertyChangeMethod originChangeMethod,
                                            ZAFFramePropertyChangeMethod sizeChangeMethod,
                                            CGFloat* origin,
                                            CGFloat* size);


@interface ZAFWindowLayoutView () <ZAFWindowViewDelegate> {

    NSImage* _desktopImage;
    ZAFWindowView* _windowView;
    ZAFAlignmentLinesView* _alignmentLinesView;
    
    ZAFWindowArea _draggingWindowArea;
    NSRect _originalWindowFrame;
    NSPoint _originalMouseLocation;
}

- (void)zaf_drawDesktopInRect:(NSRect)rect;
- (void)zaf_updateWindowLayoutProperties;

- (void)zaf_innerChangeWindowLayoutWithXPercent:(const double*)xPercent
                                       yPercent:(const double*)yPercent
                                   widthPercent:(const double*)widthPercent
                                  heightPercent:(const double*)heightPercent;

- (BOOL)zaf_areAllPropertiesZero;
- (void)zaf_assertPercentValue:(double)percent;

@end



@implementation ZAFWindowLayoutView


- (id)initWithFrame:(NSRect)frameRect {
    
    self = [super initWithFrame:frameRect];
    if (self) {
        
        _desktopImage = [NSImage imageNamed:@"Desktop"];
        
        _windowView = [[ZAFWindowView alloc] initWithFrame:NSZeroRect];
        _windowView.delegate = self;
        [self addSubview:_windowView];
        
        _alignmentLinesView = [[ZAFAlignmentLinesView alloc] initWithFrame:frameRect];
        _alignmentLinesView.hidden = YES;
        [self addSubview:_alignmentLinesView];
        
        _xPercent = 0;
        _yPercent = 0;
        _widthPercent = 0;
        _heightPercent = 0;
        
        self.enabled = YES;
    }
    return self;
}


- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    
    [super resizeSubviewsWithOldSize:oldSize];
    
    //大小改变之后要重新对子视图布局
    [self zaf_innerChangeWindowLayoutWithXPercent:&_xPercent
                                         yPercent:&_yPercent
                                     widthPercent:&_widthPercent
                                    heightPercent:&_heightPercent];
    
    _alignmentLinesView.frame = self.bounds;
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];    
    [self zaf_drawDesktopInRect:dirtyRect];
}


- (void)zaf_drawDesktopInRect:(NSRect)rect {
    
    NSRect imageRect = { 0 };
    
    imageRect.origin.x = _desktopImage.size.width * rect.origin.x / self.bounds.size.width;
    imageRect.origin.y = _desktopImage.size.height * rect.origin.y / self.bounds.size.height;
    imageRect.size.width = _desktopImage.size.width * rect.size.width / self.bounds.size.width;
    imageRect.size.height = _desktopImage.size.height * rect.size.height / self.bounds.size.height;
    
    [_desktopImage drawInRect:rect fromRect:imageRect operation:NSCompositeCopy fraction:1];
}


- (void)windowViewWillBeginDraggedInArea:(ZAFWindowArea)area fromMouseLocation:(NSPoint)mouseLocation {
    
    _draggingWindowArea = area;
    _originalWindowFrame = _windowView.frame;
    _originalMouseLocation = mouseLocation;
    
    _alignmentLinesView.hidden = NO;
}


- (void)windowViewIsBeingDraggedToMouseLocation:(NSPoint)mouseLocation {
    
    ZAFFramePropertyChangeMethod xChangeMethod = ZAFFramePropertyNotChange;
    ZAFFramePropertyChangeMethod yChangeMethod = ZAFFramePropertyNotChange;
    ZAFFramePropertyChangeMethod widthChangeMethod = ZAFFramePropertyNotChange;
    ZAFFramePropertyChangeMethod heightChangeMethod = ZAFFramePropertyNotChange;
    
    switch (_draggingWindowArea) {
            
        case ZAFWindowAreaLeftTop:
            xChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            widthChangeMethod = ZAFFramePropertyChangeOppositeToMouse;
            heightChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            break;
            
        case ZAFWindowAreaTop:
            heightChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            break;
            
        case ZAFWindowAreaRightTop:
            widthChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            heightChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            break;
            
        case ZAFWindowAreaRight:
            widthChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            break;
            
        case ZAFWindowAreaRightBottom:
            yChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            widthChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            heightChangeMethod = ZAFFramePropertyChangeOppositeToMouse;
            break;
            
        case ZAFWindowAreaBottom:
            yChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            heightChangeMethod = ZAFFramePropertyChangeOppositeToMouse;
            break;
            
        case ZAFWindowAreaLeftBottom:
            xChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            yChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            widthChangeMethod = ZAFFramePropertyChangeOppositeToMouse;
            heightChangeMethod = ZAFFramePropertyChangeOppositeToMouse;
            break;
            
        case ZAFWindowAreaLeft:
            xChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            widthChangeMethod = ZAFFramePropertyChangeOppositeToMouse;
            break;
            
        case ZAFWindowAreaCenter:
            xChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            yChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
            break;
            
        default:
            break;
    }
    
    CGFloat deltaMouseX = mouseLocation.x - _originalMouseLocation.x;
    CGFloat deltaMouseY = mouseLocation.y - _originalMouseLocation.y;
    
    NSRect newFrame = _originalWindowFrame;
    
    if (xChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
        newFrame.origin.x += deltaMouseX;
    }
    
    if (yChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
        newFrame.origin.y += deltaMouseY;
    }
    
    if (widthChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
        newFrame.size.width += deltaMouseX;
    }
    else if (widthChangeMethod == ZAFFramePropertyChangeOppositeToMouse) {
        newFrame.size.width -= deltaMouseX;
    }
    
    if (heightChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
        newFrame.size.height += deltaMouseY;
    }
    else if (heightChangeMethod == ZAFFramePropertyChangeOppositeToMouse) {
        newFrame.size.height -= deltaMouseY;
    }
    
    //调整窗口的大小和位置
    AdjustFrameDimension(self.bounds.size.width,
                         xChangeMethod,
                         widthChangeMethod,
                         &newFrame.origin.x,
                         &newFrame.size.width);
    
    AdjustFrameDimension(self.bounds.size.height,
                         yChangeMethod,
                         heightChangeMethod,
                         &newFrame.origin.y,
                         &newFrame.size.height);
    
    //把窗口吸附到特殊位置
    ZAFAlignmentLine alignmentLines = 0;
    
    if ( (xChangeMethod != ZAFFramePropertyNotChange) || (widthChangeMethod != ZAFFramePropertyNotChange) ) {
    
        ZAFStickPosition stickPosition = StickFrameDimension(self.bounds.size.width,
                                                             xChangeMethod,
                                                             widthChangeMethod,
                                                             &newFrame.origin.x,
                                                             &newFrame.size.width);
        
        if (stickPosition & ZAFStickPositionFirstEdge) {
            alignmentLines |= ZAFAlignmentLineLeft;
        }
        
        if (stickPosition & ZAFStickPositionSecondEdge) {
            alignmentLines |= ZAFAlignmentLineRight;
        }
        
        if (stickPosition & ZAFStickPositionCenter) {
            alignmentLines |= ZAFAlignmentLineVerticalCenter;
        }
    }
    
    if ( (yChangeMethod != ZAFFramePropertyNotChange) || (heightChangeMethod != ZAFFramePropertyNotChange) ) {
    
        ZAFStickPosition stickPosition = StickFrameDimension(self.bounds.size.height,
                                                             yChangeMethod,
                                                             heightChangeMethod,
                                                             &newFrame.origin.y,
                                                             &newFrame.size.height);
        
        if (stickPosition & ZAFStickPositionFirstEdge) {
            alignmentLines |= ZAFAlignmentLineBottom;
        }
        
        if (stickPosition & ZAFStickPositionSecondEdge) {
            alignmentLines |= ZAFAlignmentLineTop;
        }
        
        if (stickPosition & ZAFStickPositionCenter) {
            alignmentLines |= ZAFAlignmentLineHorizontalCenter;
        }
    }
    
    _windowView.frame = newFrame;
    [self zaf_updateWindowLayoutProperties];
    
    _alignmentLinesView.shownLines = alignmentLines;
    [_alignmentLinesView setNeedsDisplay:YES];
}


- (void)windowViewDidEndDragged {
    
    _alignmentLinesView.hidden = YES;
    _alignmentLinesView.shownLines = 0;
}


- (void)zaf_updateWindowLayoutProperties {
    
    NSRect windowFrame = _windowView.frame;
    NSRect desktopFrame = self.bounds;
    
    CGFloat flippedY = desktopFrame.size.height - windowFrame.origin.y - windowFrame.size.height;
    
    _xPercent = windowFrame.origin.x / desktopFrame.size.width;
    _yPercent = flippedY / desktopFrame.size.height;
    _widthPercent = windowFrame.size.width / desktopFrame.size.width;
    _heightPercent = windowFrame.size.height / desktopFrame.size.height;
    
    if (_delegate != nil) {
        [_delegate windowLayoutDidChangeToXPercent:_xPercent
                                          yPercent:_yPercent
                                      widthPercent:_widthPercent
                                     heightPercent:_heightPercent];
    }
}


- (BOOL)isCleared {
    
    return [self zaf_areAllPropertiesZero];
}


- (void)setXPercent:(double)xPercent {

    [self zaf_assertPercentValue:xPercent];
    
    if (self.isCleared) {
        return;
    }
    
    [self zaf_innerChangeWindowLayoutWithXPercent:&xPercent yPercent:NULL widthPercent:NULL heightPercent:NULL];
}

- (void)setYPercent:(double)yPercent {

    [self zaf_assertPercentValue:yPercent];
    
    if (self.isCleared) {
        return;
    }
    
    [self zaf_innerChangeWindowLayoutWithXPercent:NULL yPercent:&yPercent widthPercent:NULL heightPercent:NULL];
}

- (void)setWidthPercent:(double)widthPercent {

    [self zaf_assertPercentValue:widthPercent];
    
    if (self.isCleared) {
        return;
    }
    
    [self zaf_innerChangeWindowLayoutWithXPercent:NULL yPercent:NULL widthPercent:&widthPercent heightPercent:NULL];
}

- (void)setHeightPercent:(double)heightPercent {

    [self zaf_assertPercentValue:heightPercent];
    
    if (self.isCleared) {
        return;
    }
    
    [self zaf_innerChangeWindowLayoutWithXPercent:NULL yPercent:NULL widthPercent:NULL heightPercent:&heightPercent];
}


- (void)clear {
    
    [self changeWithXPercent:0 yPercent:0 widthPercent:0 heightPercent:0];
}


- (void)changeWithXPercent:(double)xPercent
                  yPercent:(double)yPercent
              widthPercent:(double)widthPercent
             heightPercent:(double)heightPercent {
 
    [self zaf_assertPercentValue:xPercent];
    [self zaf_assertPercentValue:yPercent];
    [self zaf_assertPercentValue:widthPercent];
    [self zaf_assertPercentValue:heightPercent];
    
    [self zaf_innerChangeWindowLayoutWithXPercent:&xPercent
                                         yPercent:&yPercent
                                     widthPercent:&widthPercent
                                    heightPercent:&heightPercent];
}


- (void)zaf_innerChangeWindowLayoutWithXPercent:(const double*)xPercent
                                       yPercent:(const double*)yPercent
                                   widthPercent:(const double*)widthPercent
                                  heightPercent:(const double*)heightPercent {
    
    ZAFFramePropertyChangeMethod xPercentChangeMethod = ZAFFramePropertyNotChange;
    ZAFFramePropertyChangeMethod yPercentChangeMethod = ZAFFramePropertyNotChange;
    ZAFFramePropertyChangeMethod widthPercentChangeMethod = ZAFFramePropertyNotChange;
    ZAFFramePropertyChangeMethod heightPercentChangeMethod = ZAFFramePropertyNotChange;
    
    if (xPercent != NULL) {
        _xPercent = *xPercent;
        xPercentChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
    }
    
    if (yPercent != NULL) {
        _yPercent = *yPercent;
        yPercentChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
    }
    
    if (widthPercent != NULL) {
        _widthPercent = *widthPercent;
        widthPercentChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
    }
    
    if (heightPercent != NULL) {
        _heightPercent = *heightPercent;
        heightPercentChangeMethod = ZAFFramePropertyChangeAlongWithMouse;
    }
    
    if ([self zaf_areAllPropertiesZero]) {
        
        _windowView.frame = NSZeroRect;
        
        if (_delegate != nil) {
            [_delegate windowLayoutDidClear];
        }
    }
    else {
        
        NSRect desktopFrame = self.bounds;
        NSRect newWindowFrame = NSZeroRect;
        
        newWindowFrame.size.width = desktopFrame.size.width * _widthPercent;
        newWindowFrame.size.height = desktopFrame.size.height * _heightPercent;
        
        CGFloat flippedY = desktopFrame.size.height * _yPercent;
        
        newWindowFrame.origin.x = desktopFrame.size.width * _xPercent;
        newWindowFrame.origin.y = desktopFrame.size.height - flippedY - newWindowFrame.size.height;
        
        AdjustFrameDimension(desktopFrame.size.width,
                             xPercentChangeMethod,
                             widthPercentChangeMethod,
                             &newWindowFrame.origin.x,
                             &newWindowFrame.size.width);
        
        AdjustFrameDimension(desktopFrame.size.height,
                             yPercentChangeMethod,
                             heightPercentChangeMethod,
                             &newWindowFrame.origin.y,
                             &newWindowFrame.size.height);
        
        _windowView.frame = newWindowFrame;
        
        if (_delegate != nil) {
            [_delegate windowLayoutDidChangeToXPercent:_xPercent
                                              yPercent:_yPercent
                                          widthPercent:_widthPercent
                                         heightPercent:_heightPercent];
        }
    }
}



- (void)zaf_assertPercentValue:(double)percent {
    
    NSParameterAssert(0 <= percent && percent <= 1);
}


- (BOOL)zaf_areAllPropertiesZero {
    
    return (_xPercent == 0) && (_yPercent == 0) &&
           (_widthPercent == 0) && (_heightPercent == 0);
}


- (void)setEnabled:(BOOL)enabled {
    
    _windowView.enabled = enabled;
}


@end



static void AdjustFrameDimension(CGFloat bound,
                                 ZAFFramePropertyChangeMethod originChangeMethod,
                                 ZAFFramePropertyChangeMethod sizeChangeMethod,
                                 CGFloat* origin,
                                 CGFloat* size) {
    
    NSCParameterAssert(origin != NULL);
    NSCParameterAssert(size != NULL);
    
    CGFloat originValue = *origin;
    CGFloat sizeValue = *size;
    
    if (originValue < 0) {
        
        CGFloat offset = -originValue;
        originValue += offset;
        
        if (sizeChangeMethod == ZAFFramePropertyChangeOppositeToMouse) {
            sizeValue -= offset;
        }
    }
    else if (originValue + sizeValue > bound) {
        
        if (originChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
            originValue = bound - sizeValue;
        }
        else if (sizeChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
            sizeValue = bound - originValue;
        }
    }
    
    const CGFloat minSize = bound * 0.2;

    if (sizeValue < minSize) {
        
        if (originChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
            
            CGFloat offset = sizeValue - minSize;
            originValue += offset;
            
            if (sizeChangeMethod == ZAFFramePropertyChangeOppositeToMouse) {
                sizeValue -= offset;
            }
        }
        else if (sizeChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
            sizeValue = minSize;
        }
    }
    
    *origin = originValue;
    *size = sizeValue;
}



static ZAFStickPosition StickFrameDimension(CGFloat bound,
                                            ZAFFramePropertyChangeMethod originChangeMethod,
                                            ZAFFramePropertyChangeMethod sizeChangeMethod,
                                            CGFloat* origin,
                                            CGFloat* size) {
    
    NSCParameterAssert(origin != NULL);
    NSCParameterAssert(size != NULL);
    
    ZAFStickPosition stickPosition = 0;
    
    CGFloat originValue = *origin;
    CGFloat sizeValue = *size;
    
    static const CGFloat kStickLength = 5;
    
    const CGFloat frameCenterStickPosition = (bound - sizeValue) / 2;
    const CGFloat boundCenterStickPosition = bound / 2;
    
    CGFloat offset = 0;
    
    //检查能否吸附到第一个边框
    if (originValue <= kStickLength) {
        
        //只有坐标改变的时候才能吸附
        if (originChangeMethod != ZAFFramePropertyNotChange) {
            stickPosition |= ZAFStickPositionFirstEdge;
            offset = 0 - originValue;
        }
    }
    
    //检查能否吸附到第二个边框
    if (originValue + sizeValue >= bound - kStickLength) {
        
        //坐标和尺寸同时改变的时候才能吸附
        if (sizeChangeMethod != ZAFFramePropertyChangeOppositeToMouse) {
            stickPosition |= ZAFStickPositionSecondEdge;
            offset = bound - originValue - sizeValue;
        }
    }
    
    //检查能否吸附到中央
    //检查窗口第一个边框能否吸附到中央
    if ( (originValue >= boundCenterStickPosition - kStickLength) &&
         (originValue <= boundCenterStickPosition + kStickLength) ) {
        
        if (originChangeMethod != ZAFFramePropertyNotChange) {
            stickPosition |= ZAFStickPositionCenter;
            offset = boundCenterStickPosition - originValue;
        }
    }
    //检查窗口第二个边框能否吸附到中央
    else if ( (originValue + sizeValue >= boundCenterStickPosition - kStickLength) &&
              (originValue + sizeValue <= boundCenterStickPosition + kStickLength) ) {

        if (sizeChangeMethod != ZAFFramePropertyChangeOppositeToMouse) {
            stickPosition |= ZAFStickPositionCenter;
            offset = boundCenterStickPosition - originValue - sizeValue;
        }
    }
    //检查窗口能否居中
    else if ( (originValue >= frameCenterStickPosition - kStickLength) &&
              (originValue <= frameCenterStickPosition + kStickLength) ) {

        //只有在移动的时候才能居中，也就是说第二个边框不变的时候才吸附
        if (sizeChangeMethod == ZAFFramePropertyNotChange) {
            stickPosition |= ZAFStickPositionCenter;
            offset = frameCenterStickPosition - originValue;
        }
    }
    
    //如果能够吸附到中央，并且也能吸附到其它地方，那么只保留吸附到中央的
    if ( (stickPosition & ZAFStickPositionCenter) && (stickPosition != ZAFStickPositionCenter) ) {
        stickPosition &= ZAFStickPositionCenter;
    }
    
    if (sizeChangeMethod != ZAFFramePropertyChangeAlongWithMouse) {
        originValue += offset;
    }
    
    if (sizeChangeMethod == ZAFFramePropertyChangeAlongWithMouse) {
        sizeValue += offset;
    }
    else if (sizeChangeMethod == ZAFFramePropertyChangeOppositeToMouse) {
        sizeValue -= offset;
    }
    
    *origin = originValue;
    *size = sizeValue;
    
    return stickPosition;
}
