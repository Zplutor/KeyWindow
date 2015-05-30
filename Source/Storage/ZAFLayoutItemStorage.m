#import "ZAFLayoutItemStorage.h"
#import "ZAFFrame.h"
#import "ZAFHotKey.h"
#import "ZAFLayoutItem.h"
#import "ZAFUtilities.h"


static NSString* const kIdentifierKey = @"Identifier";
static NSString* const kNameKey = @"Name";
static NSString* const kKeyCodeKey = @"KeyCode";
static NSString* const kKeyModifiersKey = @"KeyModifiers";
static NSString* const kXPercentKey = @"XPercent";
static NSString* const kYPercentKey = @"YPercent";
static NSString* const kWidthPercentKey = @"WidthPercent";
static NSString* const kHeightPercentKey = @"HeightPercent";



@interface ZAFLayoutItemStorage () {

    NSString* _storageFilePath;
    NSMutableArray* _layoutItems;
}

- (NSString*)zaf_storageFilePath;
- (NSUInteger)zaf_indexOfLayoutItemWithIdentifier:(NSString*)identifier;
- (BOOL)zaf_loadLayoutItemsIfNeeded;
- (ZAFLayoutItem*)zaf_layoutItemFromDictionary:(NSDictionary*)dictionary;
- (BOOL)zaf_saveLayoutItems;
- (NSDictionary*)zaf_dictionaryFromLayoutItem:(ZAFLayoutItem*)layoutItem;

@end



@implementation ZAFLayoutItemStorage


- (id)init {
    
    self = [super init];
    if (self) {
        _storageFilePath = [self zaf_storageFilePath];
    }
    return self;
}


- (NSString*)zaf_storageFilePath {
    
    NSArray* urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                           inDomains:NSUserDomainMask];
    
    if ((urls == nil) || (urls.count == 0)) {
        return [NSString string];
    }
    
    NSURL* url = urls[0];
    url = [url URLByAppendingPathComponent:@"KeyWindow" isDirectory:YES];
    url = [url URLByAppendingPathComponent:@"LayoutItems.plist" isDirectory:NO];
    return url.path;
}


- (NSArray*)allLayoutItems {
    
    if (! [self zaf_loadLayoutItemsIfNeeded]) {
        return [NSArray array];
    }
    return _layoutItems;
}


- (ZAFLayoutItem*)layoutItemWithIdentifier:(NSString*)identifier {
    
    NSParameterAssert(identifier != nil);
    
    if (! [self zaf_loadLayoutItemsIfNeeded]) {
        return nil;
    }
    
    NSUInteger index = [self zaf_indexOfLayoutItemWithIdentifier:identifier];
    if (index == NSNotFound) {
        return nil;
    }
    
    return _layoutItems[index];
}


- (BOOL)addLayoutItem:(ZAFLayoutItem*)item {
    
    NSParameterAssert(item != nil);
    
    if (! [self zaf_loadLayoutItemsIfNeeded]) {
        return NO;
    }
    
    //检查是否已经存在这个项
    NSUInteger index = [self zaf_indexOfLayoutItemWithIdentifier:item.identifier];
    if (index != NSNotFound) {
        return NO;
    }
    
    [_layoutItems addObject:item];
    
    if (! [self zaf_saveLayoutItems]) {
        [_layoutItems removeLastObject];
        return NO;
    }
    
    return YES;
}


- (BOOL)updateLayoutItem:(ZAFLayoutItem*)item {
    
    NSParameterAssert(item != nil);
    
    if (! [self zaf_loadLayoutItemsIfNeeded]) {
        return NO;
    }
    
    NSUInteger index = [self zaf_indexOfLayoutItemWithIdentifier:item.identifier];
    if (index == NSNotFound) {
        return NO;
    }
    
    ZAFLayoutItem* oldItem = _layoutItems[index];
    [_layoutItems replaceObjectAtIndex:index withObject:item];
    
    if (! [self zaf_saveLayoutItems]) {
        [_layoutItems replaceObjectAtIndex:index withObject:oldItem];
        return NO;
    }
    
    return YES;
}


- (BOOL)deleteLayoutItemWithIdentifier:(NSString*)identifier {
    
    NSParameterAssert(identifier != nil);
    
    if (! [self zaf_loadLayoutItemsIfNeeded]) {
        return NO;
    }
    
    NSUInteger index = [self zaf_indexOfLayoutItemWithIdentifier:identifier];
    if (index == NSNotFound) {
        return NO;
    }
    
    ZAFLayoutItem* oldItem = _layoutItems[index];
    [_layoutItems removeObjectAtIndex:index];
    
    if (! [self zaf_saveLayoutItems]) {
        [_layoutItems insertObject:oldItem atIndex:index];
        return NO;
    }
    
    return YES;
}


- (NSUInteger)zaf_indexOfLayoutItemWithIdentifier:(NSString*)identifier {
    
    return [_layoutItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        ZAFLayoutItem* eachItem = obj;
        return [eachItem.identifier isEqualToString:identifier];
    }];
}


- (BOOL)zaf_loadLayoutItemsIfNeeded {
    
    if (_layoutItems != nil) {
        return YES;
    }
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:_storageFilePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[_storageFilePath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        
        _layoutItems = [[NSMutableArray alloc] init];
        return YES;
    }
    
    NSArray* layoutItemDictionaries = [NSArray arrayWithContentsOfFile:_storageFilePath];
    _layoutItems = [[NSMutableArray alloc] initWithCapacity:layoutItemDictionaries.count];
    
    for (NSDictionary* eachDictionary in layoutItemDictionaries) {
        [_layoutItems addObject:[self zaf_layoutItemFromDictionary:eachDictionary]];
    }
    
    return YES;
}


- (ZAFLayoutItem*)zaf_layoutItemFromDictionary:(NSDictionary*)dictionary {
    
    ZAFMutableHotKey* hotKey = [[ZAFMutableHotKey alloc] init];
    
    NSNumber* keyCode = [dictionary objectForKey:kKeyCodeKey];
    if (keyCode != nil) {
        hotKey.keyCode = keyCode.intValue;
    }
    
    NSNumber* keyModifiers = [dictionary objectForKey:kKeyModifiersKey];
    if (keyModifiers != nil) {
        hotKey.keyModifiers = keyModifiers.unsignedIntegerValue;
    }
    
    ZAFMutableFrame* frame = [[ZAFMutableFrame alloc] init];
    
    NSNumber* xPercent = [dictionary objectForKey:kXPercentKey];
    if (xPercent != nil) {
        frame.xPercent = ZAFCorrectPercentValue(xPercent.doubleValue);
    }
    
    NSNumber* yPercent = [dictionary objectForKey:kYPercentKey];
    if (yPercent != nil) {
        frame.yPercent = ZAFCorrectPercentValue(yPercent.doubleValue);
    }
    
    NSNumber* widthPercent = [dictionary objectForKey:kWidthPercentKey];
    if (widthPercent != nil) {
        frame.widthPercent = ZAFCorrectPercentValue(widthPercent.doubleValue);
    }
    
    NSNumber* heightPercent = [dictionary objectForKey:kHeightPercentKey];
    if (heightPercent != nil) {
        frame.heightPercent = ZAFCorrectPercentValue(heightPercent.doubleValue);
    }
    
    ZAFMutableLayoutItem* layoutItem = [[ZAFMutableLayoutItem alloc] init];
    layoutItem.hotKey = hotKey;
    layoutItem.frame = frame;
    
    NSString* identifier = [dictionary objectForKey:kIdentifierKey];
    if (identifier != nil) {
        layoutItem.identifier = identifier;
    }
    
    NSString* name = [dictionary objectForKey:kNameKey];
    if (name != nil) {
        layoutItem.name = name;
    }
    
    return layoutItem;
}


- (BOOL)zaf_saveLayoutItems {
    
    NSMutableArray* layoutItemDictionaries = [[NSMutableArray alloc] initWithCapacity:_layoutItems.count];
    
    for (ZAFLayoutItem* eachLayoutItem in _layoutItems) {
        [layoutItemDictionaries addObject:[self zaf_dictionaryFromLayoutItem:eachLayoutItem]];
    }
    
    return [layoutItemDictionaries writeToFile:_storageFilePath atomically:YES];
}


- (NSDictionary*)zaf_dictionaryFromLayoutItem:(ZAFLayoutItem*)layoutItem {
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:layoutItem.identifier forKey:kIdentifierKey];
    [dictionary setObject:layoutItem.name forKey:kNameKey];
    [dictionary setObject:@(layoutItem.hotKey.keyCode) forKey:kKeyCodeKey];
    [dictionary setObject:@(layoutItem.hotKey.keyModifiers) forKey:kKeyModifiersKey];
    [dictionary setObject:@(layoutItem.frame.xPercent) forKey:kXPercentKey];
    [dictionary setObject:@(layoutItem.frame.yPercent) forKey:kYPercentKey];
    [dictionary setObject:@(layoutItem.frame.widthPercent) forKey:kWidthPercentKey];
    [dictionary setObject:@(layoutItem.frame.heightPercent) forKey:kHeightPercentKey];
    
    return dictionary;
}


@end


