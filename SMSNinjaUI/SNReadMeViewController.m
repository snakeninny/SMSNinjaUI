#import "SNReadMeViewController.h"

@implementation SNReadMeViewController

@synthesize fake;

- (void)dealloc
{
	[fake release];
	fake = nil;
    
	[super dealloc];
}

- (SNReadMeViewController *)init
{
	if ((self = [super init]))
	{
		self.navigationItem.title = NSLocalizedString(@"Readme", @"Readme");
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Huh?", @"Huh?") style:UIBarButtonItemStylePlain target:self action:@selector(kidding)] autorelease];
	}
	return self;
}

- (void)viewDidLoad
{
	NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
	NSString *filePath;
	NSString *readMe;
	NSError *error = nil;
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	filePath = [self.fake boolValue] ? [[NSBundle mainBundle] pathForResource:[language stringByAppendingString:@"_fake"] ofType:@"txt"] : [[NSBundle mainBundle] pathForResource:language ofType:@"txt"];
	if (![fileManager fileExistsAtPath:filePath]) filePath = [self.fake boolValue] ? [[NSBundle mainBundle] pathForResource:@"en_fake" ofType:@"txt"] : [[NSBundle mainBundle] pathForResource:@"en" ofType:@"txt"];
	readMe = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
	if (error)
	{
		NSLog(@"SMSNinja: Failed to decode %@ to UTF8, error: %@", filePath, [error localizedDescription]);
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Failed to show readme. Please try reinstalling SMSNinja.", @"Failed to show readme. Please try reinstalling SMSNinja.") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
    
	UITextView *textView = [[UITextView alloc] init];
	textView.editable = NO;
	[textView setContentToHTMLString:readMe];
	textView.font = [UIFont systemFontOfSize:16.0f];
	textView.textAlignment = NSTextAlignmentLeft;
	self.view = textView;
	[textView release];
}

- (void)kidding
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Hope is a good thing, maybe the best of things. And no good thing ever dies.", @"Hope is a good thing, maybe the best of things. And no good thing ever dies.") delegate:self cancelButtonTitle:NSLocalizedString(@"You idiot!", @"You idiot!") otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}
@end
