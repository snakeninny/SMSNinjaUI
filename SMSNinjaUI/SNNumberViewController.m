#import "SNNumberViewController.h"
#import <sqlite3.h>
#import "BlacklistViewController.h"
#import "WhitelistViewController.h"
#import "PrivatelistViewController.h"
#import "CallDetailSettingsViewController.h"
#import "SMSDetailSettingsViewController.h"

#define DOCUMENT @"/var/mobile/Library/SMSNinja"
#define SETTINGS [DOCUMENT stringByAppendingString:@"/smsninja.plist"]
#define DATABASE [DOCUMENT stringByAppendingString:@"/smsninja.db"]

@implementation SNNumberViewController

@synthesize nameString;
@synthesize keywordString;
@synthesize phoneString;
@synthesize smsString;
@synthesize replyString;
@synthesize messageString;
@synthesize forwardString;
@synthesize numberString;
@synthesize soundString;
@synthesize flag;

- (NumberViewController *)init
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"any-fucking-cell"] autorelease];

		switch (indexPath.section)
		{
			case 0:
				{
					if (indexPath.row == 0)
					{
						cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
						cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
						cell.textLabel.text = NSLocalizedString(@"Number", @"Number");
						cell.selectionStyle = UITableViewCellSelectionStyleNone;

						numberField.delegate = nil;
						[numberField release];
						numberField = [[UITextField alloc] initWithFrame:CGRectMake(100.0f, 11.0f, 200.0f, 25.0f)];
						numberField.placeholder = NSLocalizedString(@"Number here", @"Number here");
						numberField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

						NSString *tempString = self.keywordString;
						tempString = [tempString stringByReplacingOccurrencesOfString:@" " withString:@""];
						tempString = [tempString stringByReplacingOccurrencesOfString:@"-" withString:@""];
						tempString = [tempString stringByReplacingOccurrencesOfString:@"(" withString:@""];
						tempString = [tempString stringByReplacingOccurrencesOfString:@")" withString:@""];

						self.keywordString = nil;
						self.keywordString = tempString;

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
						cell.textLabel.text = NSLocalizedString(@"Call", @"Call");
						if ([self.phoneString isEqualToString:@"1"])
							cell.detailTextLabel.text = NSLocalizedString(@"Disconnect", @"Disconnect");
						else if ([self.phoneString isEqualToString:@"2"])
							cell.detailTextLabel.text = NSLocalizedString(@"Ignore", @"Ignore");
						else if ([self.phoneString isEqualToString:@"3"])
							cell.detailTextLabel.text = NSLocalizedString(@"Let go", @"Let go");
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					}
					else if (indexPath.row == 1)
					{
						cell.textLabel.text = NSLocalizedString(@"SMS", @"SMS");
						if ([self.smsString isEqualToString:@"1"])
							cell.detailTextLabel.text = NSLocalizedString(@"Block", @"Block");
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
	{
		switch (indexPath.row)
		{
			case 0:
				{
					CallDetailSettingsViewController *callDetailSettingsViewController = [[CallDetailSettingsViewController alloc] init];
					callDetailSettingsViewController.phoneString = self.phoneString;
					callDetailSettingsViewController.flag = self.flag;
					[self.navigationController pushViewController:callDetailSettingsViewController animated:YES];
					[callDetailSettingsViewController release];
					break;
				}
			case 1:
				{
					SMSDetailSettingsViewController *smsDetailSettingsViewController = [[SMSDetailSettingsViewController alloc] init];
					smsDetailSettingsViewController.smsString = self.smsString;
					smsDetailSettingsViewController.forwardString = self.forwardString;
					smsDetailSettingsViewController.numberString = self.numberString;
					[self.navigationController pushViewController:smsDetailSettingsViewController animated:YES];
					[smsDetailSettingsViewController release];
					break;
				}
		}
	}
}

- (void)saveConfig
{
	[self viewWillDisappear:YES];

	for (UIViewController *viewController in self.navigationController.viewControllers)
	{
		if ([viewController isKindOfClass:[WhitelistViewController class]] && [self.flag isEqualToString:@"white"])
		{
			WhitelistViewController *whitelistViewControllerClass = (WhitelistViewController *)viewController;
			[whitelistViewControllerClass initDB];
			[whitelistViewControllerClass.tableView reloadData];
			[self.navigationController popToViewController:whitelistViewControllerClass animated:YES];
		}
		if ([viewController isKindOfClass:[BlacklistViewController class]] && [self.flag isEqualToString:@"black"])
		{
			BlacklistViewController *blacklistViewControllerClass = (BlacklistViewController *)viewController;
			[blacklistViewControllerClass initDB];
			[blacklistViewControllerClass.tableView reloadData];
			[self.navigationController popToViewController:blacklistViewControllerClass animated:YES];
		}
		if ([viewController isKindOfClass:[PrivatelistViewController class]] && [self.flag isEqualToString:@"private"])
		{
			PrivatelistViewController *privatelistClass = (PrivatelistViewController *)viewController;
			[privatelistClass initDB];
			[privatelistClass.tableView reloadData];
			[self.navigationController popToViewController:privatelistClass animated:YES];  
		}
	}
}	

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.replyString = nil;
	self.replyString = replySwitch.on ? @"1" : @"0";

	self.soundString = nil;
	self.soundString = soundSwitch.on ? @"1" : @"0";

	self.nameString = nil;
	self.nameString = [nameField.text length] == 0 ? @"" : nameField.text;

	self.keywordString = nil;
	self.keywordString = [numberField.text length] == 0 ? @"" : numberField.text;

	self.messageString = nil;
	self.messageString = [replyField.text length] == 0 ? @"" : replyField.text;
	
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
			NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", self.flag, keyword, [nameField.text length] == 0 ? @"" : [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], self.phoneString, self.smsString, replySwitch.on == YES ? @"1" : @"0", [replyField.text length] == 0 ? @"" : [replyField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], self.forwardString, self.numberString, soundSwitch.on == YES ? @"1" : @"0"];

			if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
				NSLog(@"SNERROR: %s", [sql UTF8String]);
			sqlite3_close(database);
		}
	}
}

- (void)dealloc
{
	[nameString release];
	nameString = nil;

	[keywordString release];
	keywordString = nil;

	[phoneString release];
	phoneString = nil;

	[smsString release];
	smsString = nil;

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

	[soundSwitch release];
	soundSwitch = nil;

	[keywordArray release];
	keywordArray = nil;

	[super dealloc];
}
@end
