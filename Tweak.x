#import "Vinculum.h"
static dispatch_once_t onceToken;

%hook SBDockView
%property(nonatomic)CGRect originalFrame;
%property(nonatomic)CGRect originalBackgroundFrame;
%property(nonatomic)BOOL open;
%new()
-(UIPanGestureRecognizer *)gesture {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    return panRecognizer;
}

%new() 
-(void)move:(UIPanGestureRecognizer *)recognizer {
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
					self.open = YES;
				}];
				self.open = YES;
			} else {
				//bring to bottom 
				[UIView animateWithDuration:0.3f animations:^(void) {
					self.frame = self.originalFrame;
				} completion: ^(BOOL complete) {
					self.open = NO;
				}];
			}

		} else {
			self.open = NO;
			//self.center = CGPointMake(self.center.x,location.y);
			self.frame = CGRectMake(self.originalFrame.origin.x,
														  location.y,
															self.originalFrame.size.width,
															self.frame.size.height);

		}
}

-(void)setFrame:(CGRect)frame {
	if (!self.open) {
		%orig;
	}
}

-(id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2 {
	if ([ConfigurationManager.sharedManager isEnabled]) {
		[self addGestureRecognizer: [self gesture]];
	}
	SBDockView *orig = %orig;
	return orig;
}

-(void)layoutSubviews {
	%orig;
	if (self.frame.origin.y > 0) {
		dispatch_once (&onceToken, ^{
			self.originalFrame = self.frame;
			self.originalBackgroundFrame = self.backgroundView.frame;
		});

		if ([ConfigurationManager.sharedManager isEnabled]) {
			SBIconController *cont = [%c(SBIconController) sharedInstance];
			SBHLibraryViewController *library = cont.libraryViewController;
			UIView *libraryView = library.view;

			self.frame = CGRectMake(self.originalFrame.origin.x,
															self.originalFrame.origin.y,
															self.originalFrame.size.width,
															libraryView.frame.size.height);
															
			self.backgroundView.autoresizesSubviews = NO;
			self.backgroundView.frame = CGRectMake( self.originalBackgroundFrame.origin.x,
																							self.backgroundView.frame.origin.y,
																							self.originalBackgroundFrame.size.width,
																							libraryView.frame.size.height);

			libraryView.frame = CGRectMake(0, 
																			self.dockHeight + 10, 
																			self.originalFrame.size.width,
																			libraryView.frame.size.height);

			[self addSubview: libraryView];

			NSLog(@"dock edge %f", self.dockListOffset);
		}
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