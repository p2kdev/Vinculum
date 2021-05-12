#import "Vinculum.h"
static dispatch_once_t onceToken;

%hook SBDockView
%property(nonatomic)CGRect originalFrame;
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
					self.center = CGPointMake(self.center.x, self.originalFrame.size.height + 10);
				} completion: ^(BOOL complete) {

				}];

			} else {
				//bring to bottom 
				[UIView animateWithDuration:0.3f animations:^(void) {
					self.center = CGPointMake(self.center.x, self.originalFrame.origin.y + (self.originalFrame.size.height / 2));
				} completion: ^(BOOL complete) {

				}];
			}

		} else {
			self.center = CGPointMake(self.center.x,location.y);
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
		});
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