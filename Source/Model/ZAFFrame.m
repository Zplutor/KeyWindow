#import "ZAFFrame.h"


@interface ZAFFrame () {
@protected
    double _xPercent;
    double _yPercent;
    double _widthPercent;
    double _heightPercent;
}

@end



@implementation ZAFFrame


+ (ZAFFrame*)emptyFrame {
    return [[ZAFFrame alloc] init];
}


- (id)init {
    
    return [self initWithXPercent:0 yPercent:0 widthPercent:0 heightPercent:0];
}


- (id)initWithXPercent:(double)xPercent
              yPercent:(double)yPercent
          widthPercent:(double)widthPercent
         heightPercent:(double)heightPercent {
    
    self = [super init];
    if (self) {
        
        _xPercent = xPercent;
        _yPercent = yPercent;
        _widthPercent = widthPercent;
        _heightPercent = heightPercent;
    }
    return self;
}


- (double)xPercent {
    return _xPercent;
}


- (double)yPercent {
    return _yPercent;
}


- (double)widthPercent {
    return _widthPercent;
}


- (double)heightPercent {
    return _heightPercent;
}


- (BOOL)isEmpty {
    return
        (_xPercent == 0) &&
        (_yPercent == 0) &&
        (_widthPercent == 0) &&
        (_heightPercent == 0);
}


- (id)copyWithZone:(NSZone*)zone {
    
    return [self mutableCopyWithZone:zone];
}


- (id)mutableCopyWithZone:(NSZone*)zone {
    
    return [[ZAFMutableFrame allocWithZone:zone] initWithXPercent:_xPercent
                                                         yPercent:_yPercent
                                                     widthPercent:_widthPercent
                                                    heightPercent:_heightPercent];
}


@end



@implementation ZAFMutableFrame


+ (ZAFMutableFrame*)emptyFrame {
    return [[ZAFMutableFrame alloc] init];
}


- (void)setXPercent:(double)xPercent {
    NSParameterAssert( (0 <= xPercent) && (xPercent <= 1) );
    _xPercent = xPercent;
}


- (void)setYPercent:(double)yPercent {
    NSParameterAssert( (0 <= yPercent) && (yPercent <= 1) );
    _yPercent = yPercent;
}


- (void)setWidthPercent:(double)widthPercent {
    NSParameterAssert( (0 <= widthPercent) && (widthPercent <= 1) );
    _widthPercent = widthPercent;
}


- (void)setHeightPercent:(double)heightPercent {
    NSParameterAssert( (0 <= heightPercent) && (heightPercent <= 1) );
    _heightPercent = heightPercent;
}


@end
