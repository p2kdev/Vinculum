#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>

#include <spawn.h>

@interface PSSwitchTableCell ()
@property(nonatomic, strong) NSString *_contentString;
@end

@interface MonitorVinculumSwitch : PSSwitchTableCell
@end

@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)arg1;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;
- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (void)runServerOnCurrentThread;
@end

@interface ImageCellVinculum : PSTableCell {

    UIImageView *boxy;
    BOOL sep;
}

@end

@interface WVVinculumRootListController : PSListController

@end

