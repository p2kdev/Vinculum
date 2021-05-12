#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#include <dlfcn.h>
#define PLIST_PATH @"/var/mobile/Library/Preferences/com.irepo.vinculum2.plist"

@interface ConfigurationManager: NSObject
@property(strong,nonatomic)NSMutableDictionary* configuration;

+(ConfigurationManager *)sharedManager;
-(void)saveWithKey:(NSString *)key value:(id)value;
-(BOOL)isEnabled;
@end
