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
    [_windowLayoutView setFrame:self.bounds];
}


- (void)setLayoutFrame:(ZAFFrame*)frame {
    
    NSParameterAssert(frame != nil);
    
    [_windowLayoutView changeWithXPercent:frame.xPercent
                                 yPercent:frame.yPercent
                             widthPercent:frame.widthPercent
                            heightPercent:frame.heightPercent];
}


@end
