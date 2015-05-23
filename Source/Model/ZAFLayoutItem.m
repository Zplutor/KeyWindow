#import "ZAFLayoutItem.h"
#import "ZAFFrame.h"
#import "ZAFHotKey.h"


@interface ZAFLayoutItem () {
@protected
    NSString* _identifier;
    NSString* _name;
    ZAFHotKey* _hotKey;
    ZAFFrame* _frame;
}

@end



@implementation ZAFLayoutItem


- (ZAFLayoutItem*)emptyLayoutItem {
    return [[ZAFLayoutItem alloc] init];
}


- (id)init {
    
    self = [super init];
    if (self) {
        
        _identifier = [NSString string];
        _name = [NSString string];
        _hotKey = [ZAFHotKey emptyHotKey];
        _frame = [ZAFFrame emptyFrame];
    }
    return self;
}


- (NSString*)identifier {
    return _identifier;
}


- (NSString*)name {
    return _name;
}


- (ZAFHotKey*)hotKey {
    return _hotKey;
}


- (ZAFFrame*)frame {
    return _frame;
}


- (BOOL)isEmpty {
    return _identifier.length == 0;
}


- (id)copyWithZone:(NSZone*)zone {
    
    ZAFLayoutItem* newItem = [[[self class] allocWithZone:zone] init];
    
    newItem->_identifier = _identifier;
    newItem->_name = _name;
    newItem->_hotKey = _hotKey;
    newItem->_frame = _frame;
    
    return newItem;
}


@end



@implementation ZAFMutableLayoutItem


- (void)setIdentifier:(NSString*)identifier {
    _identifier = [identifier copy];
}


- (void)setName:(NSString*)name {
    _name = [name copy];
}


- (void)setHotKey:(ZAFHotKey*)hotKey {
    _hotKey = [hotKey copy];
}


- (void)setFrame:(ZAFFrame*)frame {
    _frame = [frame copy];
}


- (id)mutableCopyWithZone:(NSZone*)zone {
    
    return [self copyWithZone:zone];
}


@end
