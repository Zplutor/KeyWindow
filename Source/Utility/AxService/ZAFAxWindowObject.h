#import "ZAFAxObject.h"

@interface ZAFAxWindowObject : ZAFAxObject

/**
 获取窗口的位置。
 
 窗口的位置是指窗口左上角在屏幕中的坐标，
 坐标系原点是屏幕的左上角。
 
 @pre position不为NULL。
 */
- (BOOL)getPosition:(NSPoint*)position;

/**
 设置窗口的位置。
 */
- (BOOL)setPosition:(NSPoint)position;

- (BOOL)getSize:(NSSize*)size;
- (BOOL)setSize:(NSSize)size;

@end
