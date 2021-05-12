#import "ConfigurationManager.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Status.h"

@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)arg1;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;
- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (void)runServerOnCurrentThread;
@end


@interface SBDockView: UIView 
@property(nonatomic)CGRect originalFrame;
-(UIPanGestureRecognizer *)gesture;
@end