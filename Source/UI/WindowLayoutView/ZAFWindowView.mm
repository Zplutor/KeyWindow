#import "ZAFWindowView.h"


static NSRect CollapseRect(NSRect rect, CGFloat collapseThickness);
static NSCursor* LoadCursorAccordingToWindowArea(ZAFWindowArea area);
static NSCursor* LoadCursor(NSString* cursorName);


@interface ZAFWindowView () {
    
    NSMutableDictionary* _windowAreasAndTrackingTags;
    ZAFWindowArea _hoveringArea;
    NSMutableDictionary* _windowAreasAndCursors;
    NSCursor* _hoveringCursor;
}

- (void)zaf_updateTrackingRect:(NSRect)trackingRect forArea:(ZAFWindowArea)area;
- (ZAFWindowArea)zaf_windowAreaWithTrackingTag:(NSTrackingRectTag)tag;
- (NSCursor*)zaf_cursorInWindowArea:(ZAFWindowArea)area;

@end


@implementation ZAFWindowView


- (id)initWithFrame:(NSRect)frameRect {
    
    self = [super initWithFrame:frameRect];
    if (self) {
        
        _windowAreasAndTrackingTags = [[NSMutableDictionary alloc] init];
        _hoveringArea = ZAFWindowAreaNone;
        _windowAreasAndCursors = [[NSMutableDictionary alloc] init];
        
        self.alphaValue = 0.6;
        self.enabled = YES;
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    static const CGFloat kBorderThickness = 2;
    
    //画边框
    [[NSColor blackColor] setFill];
    NSBezierPath* borderPath = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:2 yRadius:2];
    [borderPath fill];
    
    //画中间
    [[NSColor darkGrayColor] setFill];
    NSRect visibleRect = CollapseRect(dirtyRect, kBorderThickness);
    NSRectFill(visibleRect);
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}



- (void)updateTrackingAreas {
    
    const CGFloat boundWidth = self.bounds.size.width;
    const CGFloat boundHeight = self.bounds.size.height;

    static const CGFloat kResizingAreaThickness = 6;

    const CGFloat topResizingAreaY = boundHeight - kResizingAreaThickness;
    const CGFloat rightResizingAreaX = boundWidth - kResizingAreaThickness;

    const CGFloat horizontalResizingAreaWidth = boundWidth - kResizingAreaThickness * 2;
    const CGFloat verticalResizineAreaHeight = boundHeight - kResizingAreaThickness * 2;

    //左上角
    NSRect topLeftRect = NSMakeRect(0, topResizingAreaY, kResizingAreaThickness, kResizingAreaThickness);
    [self zaf_updateTrackingRect:topLeftRect forArea:ZAFWindowAreaLeftTop];

    //上边
    NSRect topRect = NSMakeRect(kResizingAreaThickness,
                                topResizingAreaY,
                                horizontalResizingAreaWidth,
                                kResizingAreaThickness);
    [self zaf_updateTrackingRect:topRect forArea:ZAFWindowAreaTop];

    //右上角
    NSRect topRightRect = NSMakeRect(rightResizingAreaX,
                                     topResizingAreaY,
                                     kResizingAreaThickness,
                                     kResizingAreaThickness);
    [self zaf_updateTrackingRect:topRightRect forArea:ZAFWindowAreaRightTop];

    //右边
    NSRect rightRect = NSMakeRect(rightResizingAreaX,
                                  kResizingAreaThickness,
                                  kResizingAreaThickness,
                                  verticalResizineAreaHeight);
    [self zaf_updateTrackingRect:rightRect forArea:ZAFWindowAreaRight];

    //右下角
    NSRect bottomRightRect = NSMakeRect(rightResizingAreaX, 0, kResizingAreaThickness, kResizingAreaThickness);
    [self zaf_updateTrackingRect:bottomRightRect forArea:ZAFWindowAreaRightBottom];

    //下边
    NSRect bottomRect = NSMakeRect(kResizingAreaThickness,
                                   0,
                                   horizontalResizingAreaWidth,
                                   kResizingAreaThickness);
    [self zaf_updateTrackingRect:bottomRect forArea:ZAFWindowAreaBottom];

    //左下角
    NSRect bottomLeftRect = NSMakeRect(0, 0, kResizingAreaThickness, kResizingAreaThickness);
    [self zaf_updateTrackingRect:bottomLeftRect forArea:ZAFWindowAreaLeftBottom];

    //左边
    NSRect leftRect = NSMakeRect(0, kResizingAreaThickness, kResizingAreaThickness, verticalResizineAreaHeight);
    [self zaf_updateTrackingRect:leftRect forArea:ZAFWindowAreaLeft];

    //中间区域
    NSRect centerRect = NSMakeRect(kResizingAreaThickness,
                                   kResizingAreaThickness,
                                   horizontalResizingAreaWidth,
                                   verticalResizineAreaHeight);
    [self zaf_updateTrackingRect:centerRect forArea:ZAFWindowAreaCenter];
}
     
     
- (void)zaf_updateTrackingRect:(NSRect)trackingRect forArea:(ZAFWindowArea)area {
    
    NSParameterAssert(area != ZAFWindowAreaNone);
 
    NSNumber* oldTrackingTag = [_windowAreasAndTrackingTags objectForKey:@(area)];
    if (oldTrackingTag != nil) {
        [self removeTrackingRect:oldTrackingTag.integerValue];
    }
    
    NSTrackingRectTag newTrackingTag = [self addTrackingRect:trackingRect owner:self userData:nil assumeInside:NO];
    [_windowAreasAndTrackingTags setObject:@(newTrackingTag) forKey:@(area)];
}


- (void)mouseEntered:(NSEvent*)theEvent {
    
    if (! _enabled) {
        return;
    }
    
    _hoveringArea = [self zaf_windowAreaWithTrackingTag:theEvent.trackingNumber];
    
    NSCursor* newCursor = [self zaf_cursorInWindowArea:_hoveringArea];
    
    if (_hoveringCursor != newCursor) {
        [_hoveringCursor pop];
        _hoveringCursor = newCursor;
        [_hoveringCursor push];
    }
}


- (void)mouseExited:(NSEvent*)theEvent {

    if (! _enabled) {
        return;
    }
    
    NSTrackingRectTag exitedAreaTag = [self zaf_windowAreaWithTrackingTag:theEvent.trackingNumber];
    
    if (_hoveringArea == exitedAreaTag) {
        
        _hoveringArea = ZAFWindowAreaNone;
        [_hoveringCursor pop];
        _hoveringCursor = nil;
    }
}


- (ZAFWindowArea)zaf_windowAreaWithTrackingTag:(NSTrackingRectTag)tag {
    
    for (NSNumber* eachArea in _windowAreasAndTrackingTags.keyEnumerator) {
        NSNumber* eachTag = [_windowAreasAndTrackingTags objectForKey:eachArea];
        if (eachTag.integerValue == tag) {
            return (ZAFWindowArea)eachArea.integerValue;
        }
    }
    
    return ZAFWindowAreaNone;
}



- (NSCursor*)zaf_cursorInWindowArea:(ZAFWindowArea)area {
    
    NSCursor* cursor = [_windowAreasAndCursors objectForKey:@(area)];
    if (cursor == nil) {
        cursor = LoadCursorAccordingToWindowArea(area);
        [_windowAreasAndCursors setObject:cursor forKey:@(area)];
    }
    return cursor;
}


- (void)cursorUpdate:(NSEvent *)event {
    
    //不要调用super的方法，即去掉默认实现，否则拖动完成之后光标会变回默认的。
}


- (void)mouseDown:(NSEvent*)theEvent {
    
    if (! _enabled) {
        return;
    }
    
    if (_delegate != nil) {
        [_delegate windowViewWillBeginDraggedInArea:_hoveringArea fromMouseLocation:theEvent.locationInWindow];
    }
    
    while (YES) {
        
        NSEvent* nextEvent = [self.window nextEventMatchingMask:NSLeftMouseDraggedMask | NSLeftMouseUpMask];
        
        if (nextEvent.type == NSLeftMouseDragged) {
            
            if (_delegate != nil) {
                [_delegate windowViewIsBeingDraggedToMouseLocation:nextEvent.locationInWindow];
            }
        }
        else if (nextEvent.type == NSLeftMouseUp) {
            
            if (_delegate != nil) {
                [_delegate windowViewDidEndDragged];
            }
            break;
        }
    }
}


@end



static NSRect CollapseRect(NSRect rect, CGFloat collapseThickness) {
    
    NSRect newRect = rect;
    newRect.origin.x += collapseThickness;
    newRect.origin.y += collapseThickness;
    newRect.size.width -= collapseThickness * 2;
    newRect.size.height -= collapseThickness * 2;
    return newRect;
}


static NSCursor* LoadCursorAccordingToWindowArea(ZAFWindowArea area) {
    
    NSString* cursorName;
    
    switch (area) {
            
        case ZAFWindowAreaTop:
        case ZAFWindowAreaBottom:
            cursorName = @"UpDown";
            break;
            
        case ZAFWindowAreaLeft:
        case ZAFWindowAreaRight:
            cursorName = @"LeftRight";
            break;
            
        case ZAFWindowAreaLeftTop:
        case ZAFWindowAreaRightBottom:
            cursorName = @"LeftUpRightDown";
            break;
            
        case ZAFWindowAreaLeftBottom:
        case ZAFWindowAreaRightTop:
            cursorName = @"LeftDownRightUp";
            break;

        case ZAFWindowAreaCenter:
            cursorName = @"Move";
            break;
            
        default:
            NSCAssert(NO, @"Should not reach here.");
            break;
    }
    
    return LoadCursor(cursorName);
}


static NSCursor* LoadCursor(NSString* cursorName) {
    
    NSImage* cursorImage = [NSImage imageNamed:cursorName];
    NSPoint hotSpot = NSMakePoint(cursorImage.size.width / 2, cursorImage.size.height / 2);
    return [[NSCursor alloc] initWithImage:cursorImage hotSpot:hotSpot];
}