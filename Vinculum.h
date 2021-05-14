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

-(UIPanGestureRecognizer *)gesture;
-(void)setBackgroundView:(UIView *)arg1 ;
-(UIView *)backgroundView;
-(double)dockHeight;
-(unsigned long long)dockEdge;
-(double)dockListOffset;
//new
-(void)close;
-(void)open;
@end

@interface SBRootFolderController: NSObject
-(long long)trailingCustomViewPageIndex;
@end

@interface SBNestingViewController : UIViewController
@end

@interface SBHIconLibraryTableViewController: UITableViewController
@end

@interface SBHLibrarySearchController: UIViewController 
@end

@interface SBHLibraryViewController: SBNestingViewController 
@property (nonatomic,readonly) SBHIconLibraryTableViewController *iconTableViewController; 
-(SBHLibrarySearchController *)containerViewController;
-(UIScrollView *)contentScrollView;
-(void)addObserver:(id)arg1 ;
@end

@interface SBHIconManager 
@property (nonatomic,retain) SBHLibraryViewController *overlayLibraryViewController;
-(void)setOccludedByOverlay:(BOOL)arg1 ;
@end

@protocol SBHLibraryViewControllerObserver
@end
 
@interface SBHomeScreenOverlayController: UIViewController
@end

@interface SBIconController: NSObject 
@property (nonatomic,retain) SBHomeScreenOverlayController * homeScreenOverlayController;
@property (getter=_rootFolderController,nonatomic,readonly) SBRootFolderController * rootFolderController; 
@property (nonatomic,retain) SBHLibraryViewController *storedLibraryController;
@property (nonatomic,retain) UIView *storedLibraryView;

+(SBIconController *)sharedInstance; 
-(SBHLibraryViewController *)libraryViewController;
-(void)setLibraryViewController:(SBHLibraryViewController *)arg1 ;
@end

@interface SBHRootSidebarController
@property (nonatomic,retain) UIViewController * avocadoViewController;
@end

@interface SBIconScrollView: UIScrollView
@end