#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Status: NSObject
+(Status *)shared;
+(NSString *)getDeviceModel;
+(BOOL)isiPhoneX;
@end