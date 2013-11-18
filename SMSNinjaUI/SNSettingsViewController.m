#import "SNSettingsViewController.h"
#import "SNMainViewController.h"
#import "SNTextTableViewCell.h"

#define DOCUMENT @"/var/mobile/Library/SMSNinja"
#define SETTINGS [DOCUMENT stringByAppendingString:@"/smsninja.plist"]
#define DATABASE [DOCUMENT stringByAppendingString:@"/smsninja.db"]
#define PICTURES [DOCUMENT stringByAppendingString:@"/Pictures/"]
#define PRIVATEPICTURES [DOCUMENT stringByAppendingString:@"/PrivatePictures/"]

@implementation SNSettingsViewController

@synthesize fake;
@synthesize iconBadgeSwitch;
@synthesize statusBarBadgeSwitch;
@synthesize hideIconSwitch;
@synthesize clearSwitch;
@synthesize addressbookSwitch;
@synthesize passwordField;
@synthesize launchCodeField;

- (void)dealloc
{  
	[iconBadgeSwitch release];
	iconBadgeSwitch = nil;

	[statusBarBadgeSwitch release];
	statusBarBadgeSwitch = nil;

	[hideIconSwitch release];
	hideIconSwitch = nil;

	[clearSwitch release];
	clearSwitch = nil;

	[addressbookSwitch release];
	addressbookSwitch = nil;

	[passwordField release];
	passwordField = nil;

	[launchCodeField release];
	launchCodeField = nil;

	[super dealloc];
}

- (SNSettingsViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = NSLocalizedString(@"Settings", @"Settings");
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", @"Reset") style:UIBarButtonItemStylePlain target:self action:@selector(resetSettings)] autorelease];
        
		iconBadgeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		statusBarBadgeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		hideIconSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		clearSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		addressbookSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
		launchCodeField = [[UITextField alloc] initWithFrame:CGRectZero];		
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
			return 6;
			break;
		case 1:
			return 4;
			break;
		case 2:
			return 1;
			break;
		case 3:
			return 2;
			break;
	}

	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
			return NSLocalizedString(@"General" ,@"General");
			break;
		case 1:
			return NSLocalizedString(@"Call", @"Call");
			break;
		case 2:
			return @"";
			break;
		case 3:
			return NSLocalizedString(@"About", @"About");
			break;
	}

	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SNTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
	switch (indexPath.section)
	{
		case 0: // General
			switch (indexPath.row)
			{
				case 0:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = NSLocalizedString(@"Password", @"Password");
					cell.accessoryView = nil;

					passwordField.secureTextEntry = YES;
					passwordField.placeholder = NSLocalizedString(@"Input here", @"Input here");
					passwordField.text = [dictionary objectForKey:@"startPassword"];
					passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
					[cell.contentView addSubview:passwordField];

					break;
				case 1:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = NSLocalizedString(@"Launch code", @"Launch code");
					cell.accessoryView = nil;

					launchCodeField.secureTextEntry = YES;
					launchCodeField.placeholder = NSLocalizedString(@"Numbers only", @"Numbers only");
					launchCodeField.text = [dictionary objectForKey:@"launchCode"];
					launchCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
					[cell.contentView addSubview:launchCodeField];

					break;
				case 2:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = NSLocalizedString(@"Hide icon", @"Hide icon");
					cell.accessoryView = hideIconSwitch;
					hideIconSwitch.on = [[dictionary objectForKey:@"shouldHideIcon"] boolValue];
					[hideIconSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];

					break;
				case 3:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = NSLocalizedString(@"Icon badge", @"Icon badge");
					cell.accessoryView = iconBadgeSwitch;
					iconBadgeSwitch.on = [[dictionary objectForKey:@"shouldShowIconBadge"] boolValue];
					[iconBadgeSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];

					break;
				case 4:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = NSLocalizedString(@"Statusbar badge", @"Statusbar badge");
					cell.accessoryView = statusBarBadgeSwitch;
					statusBarBadgeSwitch.on = [[dictionary objectForKey:@"shouldShowStatusBarBadge"] boolValue];
					[statusBarBadgeSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];

					break;
				case 5:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = NSLocalizedString(@"Contacts ⊆ Whitelist", @"Contacts ⊆ Whitelist");
					cell.accessoryView = addressbookSwitch;
					addressbookSwitch.on = [[dictionary objectForKey:@"shouldIncludeContactsInWhitelist"] boolValue];
					[addressbookSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];

					break;
			}
			break;
		case 1: // Call
			switch (indexPath.row)
			{
				case 0:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.textLabel.text = NSLocalizedString(@"Whitelist calls only w/ beep", @"Whitelist calls only w/ beep");
					cell.accessoryType = [[dictionary objectForKey:@"whitelistCallsOnlyWithBeep"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
					cell.accessoryView = nil;

					break;
				case 1:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.textLabel.text = NSLocalizedString(@"Whitelist calls only w/o beep", @"Whitelist calls only w/o beep");
					cell.accessoryType = [[dictionary objectForKey:@"whitelistCallsOnlyWithoutBeep"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
					cell.accessoryView = nil;

					break;
				case 2:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.textLabel.text = NSLocalizedString(@"Whitelist msgs only w/ beep", @"Whitelist msgs only w/ beep");
					cell.accessoryType = [[dictionary objectForKey:@"whitelistMessagesOnlyWithBeep"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
					cell.accessoryView = nil;

					break;
				case 3:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.textLabel.text = NSLocalizedString(@"Whitelist msgs only w/o beep", @"Whitelist msgs only w/o beep");
					cell.accessoryType = [[dictionary objectForKey:@"whitelistMessagesOnlyWithoutBeep"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
					cell.accessoryView = nil;

					break;
			}
			break;
		case 2: // NoBlockedCallLog
			if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = NSLocalizedString(@"NoBlockedCallLog", @"NoBlockedCallLog");
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = clearSwitch;
			clearSwitch.on = [[dictionary objectForKey:@"shouldClearSpam"] boolValue];
			[clearSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];

			break;
		case 3:
			switch (indexPath.row)
			{
				case 0:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.textLabel.text = NSLocalizedString(@"Questions & Suggestions", @"Questions & Suggestions");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.accessoryView = nil;

					break;
				case 1:
					if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];

					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.textLabel.text = NSLocalizedString(@"Donate via PayPal. Thank you!", @"Donate via PayPal. Thank you!");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.accessoryView = nil;

					break;
			}
			break;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1)
	{
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];

		if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
		{
			[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;

			switch (indexPath.row)
			{
				case 0:
					[dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"whitelistCallsOnlyWithBeep"];
					break;
				case 1:
					[dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"whitelistCallsOnlyWithoutBeep"];
					break;
				case 2:
					[dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"whitelistMessagesOnlyWithBeep"];
					break;
				case 3:
					[dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"whitelistMessagesOnlyWithoutBeep"];
					break;
			}
		}
		else if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone)
		{
			[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

			if (indexPath.row == 0 || indexPath.row == 1)
			{
				[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(1 - indexPath.row) inSection:1]].accessoryType = UITableViewCellAccessoryNone;

				[dictionary setObject:[NSNumber numberWithBool:YES] forKey:indexPath.row == 0 ? @"whitelistCallsOnlyWithBeep" : @"whitelistCallsOnlyWithoutBeep"];
				[dictionary setObject:[NSNumber numberWithBool:NO] forKey:indexPath.row == 1 ? @"whitelistCallsOnlyWithBeep" : @"whitelistCallsOnlyWithoutBeep"];
			}
			else if (indexPath.row == 2 || indexPath.row == 3)
			{
				[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(5 - indexPath.row) inSection:1]].accessoryType = UITableViewCellAccessoryNone;

				[dictionary setObject:[NSNumber numberWithBool:YES] forKey:indexPath.row == 2 ? @"whitelistMessagesOnlyWithBeep" : @"whitelistMessagesOnlyWithoutBeep"];
				[dictionary setObject:[NSNumber numberWithBool:NO] forKey:indexPath.row == 3 ? @"whitelistMessagesOnlyWithBeep" : @"whitelistMessagesOnlyWithoutBeep"];
			}
		}

		[dictionary writeToFile:SETTINGS atomically:YES];
	}
	else if (indexPath.section == 3)
	{
		NSString *url;
		if (indexPath.row == 0) url = @"http://ying.lu/smsninja-faq/";
		else url = @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X5WXJTUHP7JLJ";
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

- (void)saveSettings
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
	[dictionary setObject:[NSNumber numberWithBool:iconBadgeSwitch.on] forKey:@"shouldShowIconBadge"];
	[dictionary setObject:[NSNumber numberWithBool:statusBarBadgeSwitch.on] forKey:@"shouldShowStatusBarBadge"];
	[dictionary setObject:[NSNumber numberWithBool:hideIconSwitch.on] forKey:@"shouldHideIcon"];
	[dictionary setObject:[NSNumber numberWithBool:clearSwitch.on] forKey:@"shouldClearSpam"];
	[dictionary setObject:[NSNumber numberWithBool:addressbookSwitch.on] forKey:@"shouldIncludeContactsInWhitelist"];
	[dictionary writeToFile:SETTINGS atomically:YES];
}

- (void)resetSettings
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SMSNinja", @"SMSNinja") message:NSLocalizedString(@"Are you sure to reset SMSNinja?", @"Are you sure to reset SMSNinja?") delegate:self cancelButtonTitle:NSLocalizedString(@"Forget that!", @"Forget that!") otherButtonTitles:NSLocalizedString(@"Go ahead!", @"Go ahead!") , nil];
	[alertView show];
	[alertView release];
}

void (^CreateDatabase)(void) = ^(void)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
    
	if (!([fileManager fileExistsAtPath:DOCUMENT isDirectory:&isDir] && isDir))
		[fileManager createDirectoryAtPath:DOCUMENT withIntermediateDirectories:YES attributes:nil error:nil];
    
	if (!([fileManager fileExistsAtPath:PICTURES isDirectory:&isDir] && isDir))
		[fileManager createDirectoryAtPath:PICTURES withIntermediateDirectories:YES attributes:nil error:nil];
    
	if (!([fileManager fileExistsAtPath:PRIVATEPICTURES isDirectory:&isDir] && isDir))
		[fileManager createDirectoryAtPath:PRIVATEPICTURES withIntermediateDirectories:YES attributes:nil error:nil];
    
	if (![fileManager fileExistsAtPath:SETTINGS])
		[fileManager copyItemAtPath:@"/Applications/SMSNinja.app/smsninja.plist" toPath:SETTINGS error:nil];
    
	if (![fileManager fileExistsAtPath:DATABASE])
		[fileManager copyItemAtPath:@"/Applications/SMSNinja.app/smsninja.db" toPath:DATABASE error:nil];
    
	NSString *filePath = [DOCUMENT stringByAppendingString:@"/blocked.caf"];
	if (![fileManager fileExistsAtPath:filePath])
		[fileManager copyItemAtPath:@"/System/Library/Audio/UISounds/sms-received5.caf" toPath:filePath error:nil];
    
	filePath = [DOCUMENT stringByAppendingString:@"/private.caf"];
	if (![fileManager fileExistsAtPath:filePath])
		[fileManager copyItemAtPath:@"/System/Library/Audio/UISounds/sms-received3.caf" toPath:filePath error:nil];
};

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:DOCUMENT error:nil];
		CreateDatabase();
		exit(0);
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
	[dictionary setObject:[passwordField.text length] != 0 ? passwordField.text : @"" forKey:[self.fake boolValue] ? @"fakePassword" : @"startPassword"];
	[dictionary setObject:[[[launchCodeField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] length] != 0 ? [[launchCodeField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] : @"" forKey:@"launchCode"];
	[dictionary writeToFile:SETTINGS atomically:YES];
}
@end
