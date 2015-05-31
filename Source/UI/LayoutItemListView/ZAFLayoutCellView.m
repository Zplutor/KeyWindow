#import "ZAFLayoutCellView.h"
#import "ZAFFrame.h"
#import "ZAFWindowLayoutView.h"


@interface ZAFLayoutCellView () {
    
    ZAFWindowLayoutView* _windowLayoutView;
}

- (void)zaf_initialize;

@end


@implementation ZAFLayoutCellView


- (id)initWithFrame:(NSRect)frameRect {
    
    self = [super initWithFrame:frameRect];
    if (self) {
        
        [self zaf_initialize];
    }
    return self;
}


- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self zaf_initialize];
}


- (void)zaf_initialize {
    
    _windowLayoutView = [[ZAFWindowLayoutView alloc] initWithFrame:NSZeroRect];
    _windowLayoutView.enabled = NO;
    [self addSubview:_windowLayoutView];
}


- (void)prepareForReuse {
    
    [super prepareForReuse];
    [_windowLayoutView clear];
}



- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    
    [super resizeSubviewsWithOldSize:oldSize];
    
    NSRect boundsFrame = self.bounds;
    
    NSRect windowLayoutViewFrame = { 0 };
    windowLayoutViewFrame.size.width = boundsFrame.size.height * 16 / 10;
    windowLayoutViewFrame.size.height = boundsFrame.size.height;
    windowLayoutViewFrame.origin.x = 20;
    windowLayoutViewFrame.origin.y = boundsFrame.origin.y;

    [_windowLayoutView setFrame:windowLayoutViewFrame];
}


- (void)setLayoutFrame:(ZAFFrame*)frame {
    
    NSParameterAssert(frame != nil);
    
    [_windowLayoutView changeWithXPercent:frame.xPercent
                                 yPercent:frame.yPercent
                             widthPercent:frame.widthPercent
                            heightPercent:frame.heightPercent];
}


@end
