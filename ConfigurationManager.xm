#import "ConfigurationManager.h"

#define PLIST_VALUE  "com.irepo.vinculum2"

@interface ConfigurationManager() 
@end

@implementation ConfigurationManager: NSObject

+(ConfigurationManager *)sharedManager {
  static dispatch_once_t p = 0;

  __strong static id _sharedObject = nil;

  dispatch_once(&p, ^{
      _sharedObject = [[self alloc] init];
  });

  return _sharedObject;
}

-(id)init {
  self = [super init];
  [self sync];
  [self update];
  return self;
}

-(void)update {
  CFStringRef appID = CFSTR(PLIST_VALUE);
  CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

  if (!keyList) {
      return;
  }
  self.configuration = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList,
                                                                                          appID,
                                                                                          kCFPreferencesCurrentUser,
                                                                                          kCFPreferencesAnyHost));
  CFRelease(keyList);
}

-(BOOL)isEnabled {
  return [[_configuration objectForKey:@"enabled"] boolValue];
}

-(void)sync {
  CFStringRef appID = CFSTR(PLIST_VALUE);
  CFPreferencesSynchronize(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

-(void)saveWithKey:(NSString *)key value:(id)value {
  CFPreferencesSetValue ((__bridge CFStringRef)key,(__bridge CFStringRef)value,
                                                    CFSTR(PLIST_VALUE),
                                                    kCFPreferencesCurrentUser,
                                                    kCFPreferencesAnyHost);
  [_configuration setValue:value forKey:key];
}


@end
