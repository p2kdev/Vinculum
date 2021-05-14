#import "Vinculum.h"
static dispatch_once_t onceToken;

%hook SBHIconLibraryTableViewController 
-(void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(id)arg2 {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"icon_launched" object:nil];
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

    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed) {

			if (location.y < [UIScreen mainScreen].bounds.size.height / 2 ) {
				//bring to top
				[UIView animateWithDuration:0.3f animations:^(void) {
					self.frame = CGRectMake(self.originalFrame.origin.x,
																	self.originalFrame.size.height / 2,
																	self.originalFrame.size.width,
																	self.frame.size.height);
				} completion: ^(BOOL complete) {
				}];
			} else {
				//bring to bottom 
				[self close];
			}

		} else if (recognizer.state == UIGestureRecognizerStateBegan) {
			
		} else {
			self.frame = CGRectMake(self.originalFrame.origin.x,
														  location.y,
															self.originalFrame.size.width,
															self.frame.size.height);
			[self.appLibrary endEditing: YES];
		}
}


%new() 
-(void)close {
	[self.appLibrary endEditing: YES];

	[UIView animateWithDuration:0.3f animations:^(void) {
			self.frame = self.originalFrame;
		} completion: ^(BOOL complete) {
			self.appLibrary.hidden = YES;
	}];
}

//TODO disable app library to prevent crash

-(void)setFrame:(CGRect)frame {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		self.appLibrary.alpha = ((self.originalFrame.size.height / 2.0f) / frame.origin.y);
		self.dockListView.alpha = 1 - self.appLibrary.alpha;
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
	}
	SBDockView *orig = %orig;
	return orig;
}

-(void)setBackgroundView:(UIView *)view {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		UIView *orig = view;
		orig.frame = CGRectMake(orig.frame.origin.x,
														orig.frame.origin.y,
														orig.frame.size.width,
														self.originalLibraryFrame.size.height);
		%orig(orig);
	}

	%orig;
}

-(CGRect)dockListViewFrame {
	CGRect orig = %orig;
	return CGRectMake(0, 0, orig.size.width, orig.size.height);
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
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.irepo.slock.plist"];

	if (!fileExists) {
		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"enabled" : [NSNumber numberWithBool:YES] }];
		[tempDict writeToFile:@"/var/mobile/Library/Preferences/com.irepo.slock.plist" atomically:YES];
	}
	
}