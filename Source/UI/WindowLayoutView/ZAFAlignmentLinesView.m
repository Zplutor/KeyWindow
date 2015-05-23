#import "ZAFAlignmentLinesView.h"


@interface ZAFAlignmentLinesView () {

}

@end



@implementation ZAFAlignmentLinesView


- (id)initWithFrame:(NSRect)frameRect {
    
    self = [super initWithFrame:frameRect];
    if (self) {
        
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    NSBezierPath* path = [[NSBezierPath alloc] init];
    CGFloat dashPattern[2] = { 3, 3 };
    [path setLineDash:dashPattern count:2 phase:0];
    
    CGFloat boundWidth = self.bounds.size.width;
    CGFloat boundHeight = self.bounds.size.height;
    
    if (_shownLines & ZAFAlignmentLineTop) {
        CGFloat y = boundHeight - 0.5;
        [path moveToPoint:NSMakePoint(0, y)];
        [path lineToPoint:NSMakePoint(boundWidth, y)];
    }

    if (_shownLines & ZAFAlignmentLineBottom) {
        CGFloat y = 0.5;
        [path moveToPoint:NSMakePoint(0, y)];
        [path lineToPoint:NSMakePoint(boundWidth, y)];
    }
    
    if (_shownLines & ZAFAlignmentLineLeft) {
        CGFloat x = 0.5;
        [path moveToPoint:NSMakePoint(x, 0)];
        [path lineToPoint:NSMakePoint(x, boundHeight)];
    }
    
    if (_shownLines & ZAFAlignmentLineRight) {
        CGFloat x = boundWidth - 0.5;
        [path moveToPoint:NSMakePoint(x, 0)];
        [path lineToPoint:NSMakePoint(x, boundHeight)];
    }
    
    if (_shownLines & ZAFAlignmentLineHorizontalCenter) {
        CGFloat height = boundHeight / 2;
        [path moveToPoint:NSMakePoint(0, height)];
        [path lineToPoint:NSMakePoint(boundWidth, height)];
    }
    
    if (_shownLines & ZAFAlignmentLineVerticalCenter) {
        CGFloat width = boundWidth / 2;
        [path moveToPoint:NSMakePoint(width, 0)];
        [path lineToPoint:NSMakePoint(width, boundHeight)];
    }
    
    [[NSColor colorWithRed:0.7 green:0 blue:0 alpha:1] setStroke];
    [path stroke];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end
