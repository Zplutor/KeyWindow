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

/**
 获取当前窗口是否一个Sheet窗口。
 */
- (BOOL)isSheet;

/**
 获取当前窗口的父窗口。
 
 如果当前窗口没有父窗口，返回nil。
 */
- (ZAFAxWindowObject*)parentWindow;

@end
