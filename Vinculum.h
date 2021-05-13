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
@property(nonatomic)CGRect originalLibraryFrame;
@property(nonatomic, weak) UIView* appLibrary;
@property(nonatomic) CGPoint touchLocation;

@property (nonatomic,readonly) UIView *dockListView; 
@property(nonatomic)BOOL open;

-(UIPanGestureRecognizer *)gesture;
-(void)setBackgroundView:(UIView *)arg1 ;
-(UIView *)backgroundView;
-(double)dockHeight;
-(unsigned long long)dockEdge;
-(double)dockListOffset;
//new
-(void)close;
@end

@interface SBHLibraryViewController: UIViewController 
-(UIScrollView *)contentScrollView;
@end

@interface SBHIconManager 
@property (nonatomic,retain) SBHLibraryViewController *overlayLibraryViewController;
@end

@interface SBIconController
@property (nonatomic,retain) SBHLibraryViewController *storedLibraryController;
+(SBIconController *)sharedInstance; 
-(SBHLibraryViewController *)libraryViewController;
@end