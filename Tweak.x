#import "Vinculum.h"
static dispatch_once_t onceToken;

%hook SBHIconLibraryTableViewController 
-(void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(id)arg2 {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"icon_launched" object:nil];
	%orig;
}

%end

%hook SBUIController
-(void)restoreContentAndUnscatterIconsAnimated:(BOOL)arg1 {
		NSLog(@"block before");

    // void (^newBlock)(void) = ^{
		// 	NSLog(@"block");
		// 	arg2();
    // };
		%orig;
}
%end

%hook SBIconController 
-(void)iconManager:(id)arg1 rootFolderController:(id)arg2 didOverscrollOnLastPageByAmount:(double)arg3 {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		self.homeScreenOverlayController = nil;
	} else {
		%orig;
	}
}

-(BOOL)isAppLibrarySupported {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		return YES;
	}
	return %orig;
}
%end

//prevents embedding of the SBHLibaryViewController 
%hook SBHRootSidebarController

-(void)_configureAvocadoViewController {
	if (![ConfigurationManager.sharedManager isEnabled]) {
		%orig;
	}

	if (![self.avocadoViewController isKindOfClass: %c(SBHLibraryViewController)]) {
		%orig;
	}
}

%end

%hook SBHLibraryViewController 
-(void)iconTapped:(id)arg1 {
	if (![arg1 isKindOfClass: %c(SBHLibraryCategoryPodIconView)]) {
		CGPoint point = CGPointMake(0, self.view.frame.origin.y);
		[self.contentScrollView setContentOffset: point animated:YES];
  	[[NSNotificationCenter defaultCenter] postNotificationName:@"icon_launched" object:nil];
	}
	%orig;
}

%end

%hook SBDockView
%property(nonatomic)CGRect originalFrame;
%property(nonatomic)CGRect originalBackgroundFrame;
%property(nonatomic)CGRect originalLibraryFrame;
%property(nonatomic, strong) UIView* appLibrary;

%new()
-(UIPanGestureRecognizer *)gesture {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    return panRecognizer;
}

%new() 
-(void)move:(UIPanGestureRecognizer *)recognizer {
	self.appLibrary.hidden = NO;
	CGPoint location = [recognizer locationInView: recognizer.view.superview];
	CGPoint velocity = [recognizer velocityInView: recognizer.view.superview];

	if (recognizer.state == UIGestureRecognizerStateEnded ||
			recognizer.state == UIGestureRecognizerStateCancelled ||
			recognizer.state == UIGestureRecognizerStateFailed) {

		if (velocity.y > 100) {
			//down
			[self close];
		} else if (velocity.y < -100) {
			//up
			[self open];
		} else {

			if (location.y < [UIScreen mainScreen].bounds.size.height / 2 ) {
				//bring to top
				[self open];
			} else {
			//bring to bottom 
				[self close];
			}
		}

	} else if (recognizer.state == UIGestureRecognizerStateBegan) {
		//begin swipe. Not used yet. 
	} else {

		self.frame = CGRectMake(self.originalFrame.origin.x,
														location.y,
														self.originalFrame.size.width,
														self.frame.size.height);
	}
}

%new() 
-(void)open {
	[UIView animateWithDuration:0.3f animations:^(void) {
		self.frame = CGRectMake(self.originalFrame.origin.x,
														self.originalFrame.size.height / 2,
														self.originalFrame.size.width,
														self.frame.size.height);
	} completion: ^(BOOL complete) {
		
	}];
}

%new() 
-(void)close {
	[UIView animateWithDuration:0.3f animations:^(void) {
			self.frame = self.originalFrame;
		} completion: ^(BOOL complete) {
			self.appLibrary.hidden = YES;
	}];
}

-(void)setFrame:(CGRect)frame {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		self.appLibrary.alpha = ((self.originalFrame.size.height / 2.0f) / frame.origin.y);
		self.dockListView.alpha = 1 - self.appLibrary.alpha;
		[self.appLibrary endEditing: YES];
	}
	%orig;
}

-(id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2 {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		[self addGestureRecognizer: [self gesture]];
		[[NSNotificationCenter defaultCenter] addObserver:self
																			selector:@selector(close)
																			name:@"icon_launched"
																			object:nil];

		static dispatch_once_t oncePrefToken;

    dispatch_once (&oncePrefToken, ^{
        CPDistributedMessagingCenter *messagingCenter;

        messagingCenter = [%c(CPDistributedMessagingCenter) centerNamed:@"com.irepo.vinculum2.preferences.updated"];
        [messagingCenter runServerOnCurrentThread];
        [messagingCenter registerForMessageName:@"PreferencesDidChangeNotification" target:self selector:@selector(preferencesUpdated:withUserInfo:)];

    });
	}
	SBDockView *orig = %orig;
	return orig;
}

%new()
-(void)preferencesUpdated:(id)notification withUserInfo:(NSDictionary *)info {
		NSLog(@"changed");
    NSString *name = [NSString stringWithFormat:@"%@",info[@"name"]];

		if ([ConfigurationManager.sharedManager isEnabled]) {
 				if ([name isEqualToString:@"Show Search First"]) {
						id value = info[@"value"];
            [[ConfigurationManager.sharedManager configuration] setObject: value forKey:@"showSearchFirst"];

						SBIconController *cont = [%c(SBIconController) sharedInstance];
						SBHLibraryViewController *library = cont.libraryViewController;
						SBHLibrarySearchController *search = library.containerViewController;

						if ([ConfigurationManager.sharedManager showSearchFirst]) {
							[search _performPresentation: YES];
						} else {
							[search _dismissPresentation: YES];
						}
        }
		}
}

-(void)setBackgroundView:(UIView *)view {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		UIView *orig = view;
		orig.frame = CGRectMake(orig.frame.origin.x,
														orig.frame.origin.y,
														orig.frame.size.width,
														self.originalLibraryFrame.size.height);
		%orig(orig);
		return;
	}

	%orig;
}

-(void)layoutSubviews {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		
		if (self.frame.origin.y > 0) {

			SBIconController *cont = [%c(SBIconController) sharedInstance];
			SBHLibraryViewController *library = cont.libraryViewController;	
			UIView *libraryView = library.view;

			dispatch_once(&onceToken, ^{
				%orig;
				self.originalFrame = self.frame;
				self.originalBackgroundFrame = self.backgroundView.frame;
				self.originalLibraryFrame = libraryView.frame;
				self.appLibrary = libraryView;
				self.appLibrary.alpha = 0.0;
				self.appLibrary.hidden = YES;

				UIEdgeInsets original = library.contentScrollView.contentInset;
				library.contentScrollView.contentInset = UIEdgeInsetsMake(original.top, 
																																	original.left, 
																																	self.dockHeight, 
																																	original.right);

				UIEdgeInsets originalTable = library.iconTableViewController.tableView.contentInset;
				library.iconTableViewController.tableView.contentInset = UIEdgeInsetsMake(originalTable.top,
																																								  originalTable.left, 
																																									self.dockHeight, 
																																									originalTable.right);
			});
		
			self.autoresizesSubviews = NO;
			self.frame = CGRectMake(self.originalFrame.origin.x,
															self.frame.origin.y,
															self.frame.size.width,
															self.originalLibraryFrame.size.height);

			self.dockListView.frame = CGRectMake(0, 0, self.dockListView.frame.size.width, self.dockListView.frame.size.height);
															
			self.backgroundView.autoresizesSubviews = NO;
			self.clipsToBounds = YES;
			self.backgroundView.frame = CGRectMake(self.originalBackgroundFrame.origin.x,
																						 self.backgroundView.frame.origin.y,
																						 self.originalBackgroundFrame.size.width,
																						 self.originalLibraryFrame.size.height);
			
			self.appLibrary.frame = CGRectMake(0, 
																				 0, 
																				 self.originalFrame.size.width,
																				 self.originalLibraryFrame.size.height - 100);

			if (![self.appLibrary isDescendantOfView: self]) {
				[self addSubview: self.appLibrary];
			}
		}
	} else {
		%orig;
	}
}

%end

%ctor {
	NSLog(@"Loading Vinculum 2 (1.0.0)");
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH];

	if (!fileExists) {
		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"enabled" : [NSNumber numberWithBool:YES],
																																											 @"showSearchFirst": [NSNumber numberWithBool: NO] }];
		[tempDict writeToFile:PLIST_PATH atomically:YES];
	}
}