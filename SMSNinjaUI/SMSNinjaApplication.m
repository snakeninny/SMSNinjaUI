#import "SMSNinjaApplication.h"
#import <objc/runtime.h>
#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"

@implementation SMSNinjaApplication

@synthesize window = _window;

- (void)dealloc
{
	[_window release];
	_window = nil;
    
	[_viewController release];
	_viewController = nil;
    
	[navigationController release];
	navigationController = nil;
    
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _viewController = [[SNMainViewController alloc] init];
    navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];
    
	[self showPasswordAlert];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self updateBadge];
}

- (void)showPasswordAlert
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:SETTINGS] && [[[NSDictionary dictionaryWithContentsOfFile:SETTINGS] objectForKey:@"startPassword"] length] != 0)
	{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Let me in!", @"Let me in!") otherButtonTitles:NSLocalizedString(@"Never mind", @"Never mind") , nil];
        [alertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        [alertView show];
        [alertView release];
	}
    else
    {
        _viewController.fake = nil;
        _viewController.fake = [NSNumber numberWithBool:NO];
        self.window.rootViewController = navigationController;
        [_window makeKeyAndVisible];
    }
}

- (void)updateBadge
{
    CPDistributedMessagingCenter *messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.naken.smsninjaspringboard"];
	[messagingCenter sendMessageName:@"UpdateBadge" userInfo:nil];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"Password here", @"Password here");
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *password = [alertView textFieldAtIndex:0].text;
    
	if (buttonIndex == 0)
	{
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:SETTINGS];
		if ([[dictionary objectForKey:@"startPassword"] isEqualToString:password] && [password length] != 0)
		{
			_viewController.fake = nil;
			_viewController.fake = [NSNumber numberWithBool:NO];
            self.window.rootViewController = navigationController;
			[_window makeKeyAndVisible];
		}
		else if ([[dictionary objectForKey:@"fakePassword"] isEqualToString:password] && [password length] != 0)
		{
			_viewController.fake = nil;
			_viewController.fake = [NSNumber numberWithBool:YES];
            self.window.rootViewController = navigationController;
			[_window makeKeyAndVisible];
		}
		else exit(0);
	}
	else exit(0);
}
@end
