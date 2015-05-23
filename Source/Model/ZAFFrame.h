#import <Foundation/Foundation.h>


@interface ZAFFrame : NSObject <NSCopying>

+ (ZAFFrame*)emptyFrame;

- (id)initWithXPercent:(double)xPercent
              yPercent:(double)yPercent
          widthPercent:(double)widthPercent
         heightPercent:(double)heightPercent;

- (double)xPercent;
- (double)yPercent;
- (double)widthPercent;
- (double)heightPercent;

- (BOOL)isEmpty;

@end


@interface ZAFMutableFrame : ZAFFrame <NSMutableCopying>

+ (ZAFMutableFrame*)emptyFrame;

- (void)setXPercent:(double)xPercent;
- (void)setYPercent:(double)yPercent;
- (void)setWidthPercent:(double)widthPercent;
- (void)setHeightPercent:(double)heightPercent;

@end