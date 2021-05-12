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
@property(nonatomic)CGRect originalBackgroundFrame;
@property (nonatomic,readonly) UIView *dockListView; 
@property(nonatomic)BOOL open;

-(UIPanGestureRecognizer *)gesture;
-(void)setBackgroundView:(UIView *)arg1 ;
-(UIView *)backgroundView;
-(double)dockHeight;
-(unsigned long long)dockEdge;
-(double)dockListOffset;
@end

@interface SBHLibraryViewController: UIViewController 
@end

@interface SBHIconManager 
@property (nonatomic,retain) SBHLibraryViewController *overlayLibraryViewController;
@end

@interface SBIconController
+(SBIconController *)sharedInstance; 
-(SBHLibraryViewController *)libraryViewController;
@end