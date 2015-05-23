#import <Cocoa/Cocoa.h>


typedef NS_OPTIONS(NSInteger, ZAFAlignmentLine) {

    ZAFAlignmentLineTop              = 1 << 0,
    ZAFAlignmentLineBottom           = 1 << 1,
    ZAFAlignmentLineLeft             = 1 << 2,
    ZAFAlignmentLineRight            = 1 << 3,
    ZAFAlignmentLineHorizontalCenter = 1 << 4,
    ZAFAlignmentLineVerticalCenter   = 1 << 5,
};


@interface ZAFAlignmentLinesView : NSView

@property (nonatomic) ZAFAlignmentLine shownLines;

@end
