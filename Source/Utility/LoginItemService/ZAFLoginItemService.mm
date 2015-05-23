#import "ZAFLoginItemService.h"
#import "ZAFLoginItem.h"


@interface ZAFLoginItemService () {
    
    LSSharedFileListRef _sharedFileList;
}

@end



@implementation ZAFLoginItemService


+ (ZAFLoginItemService*)defaultService {
    
    static ZAFLoginItemService* instance = [[ZAFLoginItemService alloc] init];
    return instance;
}


- (id)init {
    
    self = [super init];
    if (self) {
        
        _sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    }
    return self;
}


- (void)dealloc {

    if (_sharedFileList != NULL) {
        CFRelease(_sharedFileList);
    }
}


- (NSArray*)loginItems {
    
    UInt32 seed = 0;
    CFArrayRef loginItemsSnapshot = LSSharedFileListCopySnapshot(_sharedFileList, &seed);
    
    if (loginItemsSnapshot == NULL) {
        return [NSArray array];
    }
    
    CFIndex totalCount = CFArrayGetCount(loginItemsSnapshot);
    NSMutableArray* loginItems = [[NSMutableArray alloc] initWithCapacity:totalCount];
    
    for (CFIndex index = 0; index < totalCount; ++index) {
        
        LSSharedFileListItemRef eachHandle = (LSSharedFileListItemRef)CFArrayGetValueAtIndex(loginItemsSnapshot, index);
        CFRetain(eachHandle);
        
        ZAFLoginItem* eachItem = [[ZAFLoginItem alloc] initWithHandle:eachHandle];
        [loginItems addObject:eachItem];
    }
    
    CFRelease(loginItemsSnapshot);
    return loginItems;
}


- (ZAFLoginItem*)addOrUpdateLoginItemWithUrl:(NSURL*)url
                                  setOptions:(NSDictionary*)setOptions
                                clearOptions:(NSArray*)clearOptions {
    
    NSParameterAssert(url != nil);
    
    LSSharedFileListItemRef newItemHandle = LSSharedFileListInsertItemURL(_sharedFileList,
                                                                          kLSSharedFileListItemLast,
                                                                          NULL,
                                                                          NULL,
                                                                          (__bridge CFURLRef)url,
                                                                          (__bridge CFDictionaryRef)setOptions,
                                                                          (__bridge CFArrayRef)clearOptions);
    
    if (newItemHandle == NULL) {
        return nil;
    }
    
    return [[ZAFLoginItem alloc] initWithHandle:newItemHandle];
}


- (BOOL)deleteLoginItem:(ZAFLoginItem*)loginItem {
    
    OSStatus result = LSSharedFileListItemRemove(_sharedFileList, loginItem.handle);
    return result == 0;
}


@end
