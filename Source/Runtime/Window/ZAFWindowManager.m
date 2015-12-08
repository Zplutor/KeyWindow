#import "ZAFWindowManager.h"
#import <AppKit/AppKit.h>
#import "ZAFAxService.h"
#import "ZAFFrame.h"


@interface ZAFWindowManager () {
    
}

- (NSRect)zaf_windowShownArea;
- (BOOL)zaf_setFocusedWindowFrame:(NSRect)frame;
- (ZAFAxWindowObject*)zaf_focusedWindow;

@end



@implementation ZAFWindowManager


- (id)init {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (BOOL)moveAndResizeFocusedWindowWithFrame:(ZAFFrame*)frame {
    
    NSParameterAssert(frame != nil);
    
    if (frame.isEmpty) {
        return NO;
    }
    
    NSRect shownArea = [self zaf_windowShownArea];
    
    NSRect windowFrame = NSMakeRect(shownArea.size.width * frame.xPercent + shownArea.origin.x,
                                    shownArea.size.height * frame.yPercent + shownArea.origin.y,
                                    shownArea.size.width * frame.widthPercent,
                                    shownArea.size.height * frame.heightPercent);
    
    return [self zaf_setFocusedWindowFrame:windowFrame];
}


- (NSRect)zaf_windowShownArea {
    
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    
    NSRect area = [[NSScreen mainScreen] visibleFrame];
    area.origin.y = screenFrame.size.height - area.origin.y - area.size.height;
    
    return area;
}


- (BOOL)zaf_setFocusedWindowFrame:(NSRect)frame {

    ZAFAxWindowObject* focusedWindow = [self zaf_focusedWindow];
    if (focusedWindow == nil) {
        return NO;
    }
    
    if (! [focusedWindow setPosition:frame.origin]) {
        return NO;
    }
    
    return [focusedWindow setSize:frame.size];
}


- (ZAFAxWindowObject*)zaf_focusedWindow {
    
    ZAFAxSystemWideObject* systemWideObject = [ZAFAxService systemWideAccessibilityObject];
    if (systemWideObject == nil) {
        return nil;
    }
    
    ZAFAxApplicationObject* focusedApplicationObject = systemWideObject.focusedApplication;
    if (focusedApplicationObject == nil) {
        return nil;
    }
    
    ZAFAxWindowObject* focusedWindowObject = focusedApplicationObject.focusedWindow;
    if (focusedWindowObject == nil) {
        return nil;
    }
    
    if (focusedWindowObject.isSheet) {
        focusedWindowObject = focusedWindowObject.parentWindow;
    }
    
    return focusedWindowObject;
}


@end
