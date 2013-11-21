#import "SNContentViewController.h"
#import <sqlite3.h>

#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"
// 到此
@implementation SNContentViewController

@synthesize nameString;
@synthesize keywordString;
@synthesize replyString;
@synthesize messageString;
@synthesize forwardString;
@synthesize numberString;
@synthesize soundString;
@synthesize flag;

- (ContentViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = NSLocalizedString(@"Details", @"Details");

		UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101];
		[backButton addTarget:self action:@selector(saveConfig) forControlEvents:UIControlEventTouchUpInside];
		[backButton setTitle:NSLocalizedString(@"List", @"List") forState:UIControlStateNormal];
		UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
		self.navigationItem.leftBarButtonItem = [backItem autorelease];

		[keywordArray release];
		keywordArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)saveConfig
{
	NSString *tempString = [numberField.text length] == 0 ? @"" : numberField.text;
	NSRange range = [tempString rangeOfString:@" "];
	while (range.location != NSNotFound )
	{
		if ([[tempString substringToIndex:range.location] length] != 0)
			[keywordArray addObject:[tempString substringToIndex:range.location]];
		tempString = [tempString substringFromIndex:range.location + 1];
		range = [tempString rangeOfString:@" "];
	}
	if ([tempString length] != 0)
		[keywordArray addObject:tempString];

	sqlite3 *database;
	for (NSString *keyword in keywordArray)
	{
		if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
		{
			NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '1', '%@', '0', '1', '%@', '%@', '%@', '%@', '%@')", self.flag, keyword, [nameField.text length] == 0 ? @"" : [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], replySwitch.on == YES ? @"1" : @"0", [replyField.text length] == 0 ? @"" : [replyField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], forwardSwitch.on == YES ? @"1" : @"0", [forwardField.text length] == 0 ? @"" : [forwardField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], soundSwitch.on == YES ? @"1" : @"0"];
			if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
				NSLog(@"SNERROR: %s", [sql UTF8String]);
			sqlite3_close(database);
		}
	}

	for (UIViewController *viewController in self.navigationController.viewControllers)
	{
		if ([viewController isKindOfClass:[WhitelistViewController class]] && [self.flag isEqualToString:@"white"])
		{
			WhitelistViewController *whitelistClass = (WhitelistViewController *)viewController;
			[whitelistClass initDB];
			[whitelistClass.tableView reloadData];
			[self.navigationController popToViewController:whitelistClass animated:YES];
		}
		if ([viewController isKindOfClass:[BlacklistViewController class]] && [self.flag isEqualToString:@"black"])
		{
			BlacklistViewController *blacklistViewControllerClass= (BlacklistViewController *)viewController;
			[blacklistViewControllerClass initDB];
			[blacklistViewControllerClass.tableView reloadData];
			[self.navigationController popToViewController:blacklistViewControllerClass animated:YES];
		}
		if ([viewController isKindOfClass:[PrivatelistViewController class]] && [self.flag isEqualToString:@"private"])
		{
			PrivatelistViewController *privatelistViewControllerClass= (PrivatelistViewController *)viewController;
			[privatelistViewControllerClass initDB];
			[privatelistViewControllerClass.tableView reloadData];
			[self.navigationController popToViewController:privatelistViewControllerClass animated:YES];
		}
	}
}	

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([self.flag isEqualToString:@"white"])
		return 1;
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 3)
		return 1;
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];

	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-fucking-cell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		switch (indexPath.section)
		{
			case 0:
				{
					if (indexPath.row == 0)
					{
						cell.textLabel.text = NSLocalizedString(@"Name", @"Name");

						nameField.delegate = nil;
						[nameField release];
						nameField = [[UITextField alloc] initWithFrame:CGRectMake(100.0f, 11.0f, 200.0f, 25.0f)];
						nameField.placeholder = NSLocalizedString(@"Name here", @"Name here");
						nameField.text = self.nameString;
						nameField.delegate = self;
						nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
						[cell.contentView addSubview:nameField];
					}
					else if (indexPath.row == 1)
					{
						cell.textLabel.text = NSLocalizedString(@"Keyword", @"Keyword");

						numberField.delegate = nil;
						[numberField release];
						numberField = [[UITextField alloc] initWithFrame:CGRectMake(100.0f, 11.0f, 200.0f, 25.0f)];
						numberField.placeholder = NSLocalizedString(@"Keyword here", @"Keyword here");
						numberField.text = self.keywordString;
						numberField.delegate = self;
						numberField.clearButtonMode = UITextFieldViewModeWhileEditing;
						[cell.contentView addSubview:numberField];
					}
					break;
				}
			case 1:
				{
					if (indexPath.row == 0)
					{
						cell.textLabel.text = NSLocalizedString(@"Forward", @"Forward");
						cell.selectionStyle = UITableViewCellSelectionStyleNone;

						[forwardSwitch release];
						forwardSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
						cell.accessoryView = forwardSwitch;
						forwardSwitch.on = [self.forwardString isEqualToString:@"0"] ? NO : YES;
					}
					else if (indexPath.row == 1)
					{
						cell.textLabel.text = NSLocalizedString(@"To", @"To");
						cell.selectionStyle = UITableViewCellSelectionStyleNone;

						forwardField.delegate = nil;
						[forwardField release];
						forwardField = [[UITextField alloc] initWithFrame:CGRectMake(120.0f, 11.0f, 180.0f, 25.0f)];
						forwardField.text = self.numberString;
						forwardField.delegate = self;
						forwardField.clearButtonMode = UITextFieldViewModeWhileEditing;
						forwardField.placeholder = NSLocalizedString(@"Number here", @"Number here");
						[cell.contentView addSubview:forwardField];
					}
					break;
				}
			case 2:
				{
					if (indexPath.row == 0)
					{
						cell.textLabel.text = NSLocalizedString(@"Auto reply", @"Auto reply");
						cell.selectionStyle = UITableViewCellSelectionStyleNone;

						[replySwitch release];
						replySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
						cell.accessoryView = replySwitch;
						replySwitch.on = [self.replyString isEqualToString:@"0"] ? NO : YES;
					}
					else if (indexPath.row == 1)
					{
						cell.textLabel.text = NSLocalizedString(@"With", @"With");
						cell.selectionStyle = UITableViewCellSelectionStyleNone;

						replyField.delegate = nil;
						[replyField release];
						replyField = [[UITextField alloc] initWithFrame:CGRectMake(120.0f, 11.0f, 180.0f, 25.0f)];
						replyField.text = self.messageString;
						replyField.delegate = self;
						replyField.clearButtonMode = UITextFieldViewModeWhileEditing;
						replyField.placeholder = NSLocalizedString(@"Message here", @"Message here");
						[cell.contentView addSubview:replyField];
					}
					break;
				}
			case 3:
				{
					cell.textLabel.text = NSLocalizedString(@"Beep", @"Beep");
					cell.selectionStyle = UITableViewCellSelectionStyleNone;

					[soundSwitch release];
					soundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
					cell.accessoryView = soundSwitch;
					soundSwitch.on = [self.soundString isEqualToString:@"0"] ? NO : YES;
					[cell.contentView addSubview:soundSwitch];
					break;
				}
		}
	}
	return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)dealloc
{
	[nameString release];
	nameString = nil;

	[keywordString release];
	keywordString = nil;

	[replyString release];
	replyString = nil;

	[messageString release];
	messageString = nil;

	[forwardString release];
	forwardString = nil;

	[numberString release];
	numberString = nil;

	[soundString release];
	soundString = nil;

	[flag release];
	flag = nil;

	[nameField release];
	nameField = nil;

	[numberField release];
	numberField = nil;

	[replySwitch release];
	replySwitch = nil;

	[replyField release];
	replyField = nil;

	[forwardSwitch release];
	forwardSwitch = nil;

	[forwardField release];
	forwardField = nil;

	[soundSwitch release];
	soundSwitch = nil;

	[keywordArray release];
	keywordArray = nil;

	[super dealloc];
}
@end
