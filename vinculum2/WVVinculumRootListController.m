#include "WVVinculumRootListController.h"
#include <dlfcn.h>
#include <spawn.h>

@implementation WVVinculumRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)apply {

    pid_t pid;
    const char* args[] = {"killall", "-9", "backboardd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end


@implementation ImageCellVinculum

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))  {
        self.backgroundView = [[UIView alloc] init];
        self.backgroundColor = [UIColor clearColor];
        boxy = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,0,0)];
        [self addSubview:boxy];
	}

    return self;

}

- (void)layoutSubviews {
	[super layoutSubviews];
  self.backgroundColor = [UIColor clearColor];

  if (!sep) {

      self.separatorStyle = UITableViewCellSeparatorStyleNone;
      sep = YES;

  } else {

      sep = NO;
  }

  CGFloat xPadding = (self.bounds.size.width / 2) - 174.5;

  [boxy setFrame:CGRectMake(xPadding, -10.0, 349, 93.0)];

  UIImage *image =  [[UIImage alloc] initWithContentsOfFile: @"/Library/PreferenceBundles/Vinculum2.bundle/nexus-prefs@2x.png"];
  [boxy setImage : image];

  boxy.layer.shadowColor = [UIColor blackColor].CGColor;
  boxy.layer.shadowOffset = CGSizeMake(0, 3);
  boxy.layer.shadowOpacity = 0.4;
  boxy.layer.shadowRadius = 1.0;
}

@end