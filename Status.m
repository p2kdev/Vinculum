#import "Status.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface Status() 
+(NSArray *)notchDevices;
@end

@implementation Status 
+(Status *)shared {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];

    });
    return _sharedObject;
}

+ (NSString *)getDeviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *sDeviceModel = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    return sDeviceModel;
}

+ (NSArray *)notchDevices {
    return @[
            @"iPhone10,3",
            @"iPhone10,6",
            @"iPhone11,6",
            @"iPhone11,4",      
            @"iPhone11,2",
            @"iPhone11,8",
            @"iPhone12,1",
            @"iPhone12,3",
            @"iPhone12,5",
            @"iPhone12,8",
            @"iPhone13,1",
            @"iPhone13,2", 
            @"iPhone13,3",
            @"iPhone13,4" 
            ];
}

+(BOOL)isiPhoneX {
    return [[Status notchDevices] containsObject: [Status getDeviceModel]];
}
@end