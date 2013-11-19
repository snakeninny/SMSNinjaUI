#import "SNMainViewController.h"
#import "SNBlockedMessageHistoryViewController.h"
#import "SNBlacklistViewController.h"
#import "SNSettingsViewController.h"
#import "SNReadMeViewController.h"
#import "SNPrivateViewController.h"
#import <sqlite3.h>

#define DOCUMENT @"/var/mobile/Library/SMSNinja"
#define SETTINGS [DOCUMENT stringByAppendingString:@"/smsninja.plist"]
#define DATABASE [DOCUMENT stringByAppendingString:@"/smsninja.db"]
#define PICTURES [DOCUMENT stringByAppendingString:@"/Pictures/"]
#define PRIVATEPICTURES [DOCUMENT stringByAppendingString:@"/PrivatePictures/"]

@implementation SNMainViewController

@synthesize fake;

- (void)dealloc
{
	[fake release];
	fake = nil;
    
	[appSwitch release];
	appSwitch = nil;
    
	[super dealloc];
}

- (SNMainViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = NSLocalizedString(@"SMSNinja", @"SMSNinja");
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"Settings") style:UIBarButtonItemStylePlain target:self action:@selector(gotoSettingsView)] autorelease];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Readme", @"Readme") style:UIBarButtonItemStylePlain target:self action:@selector(gotoReadMeView)] autorelease];

        appSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    }
	return self;
}

- (void)viewDidLoad
{
	[self updateDatabase];
    
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *view = self.tableView;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	[label setText:NSLocalizedString(@"by Yinglu Zou (snakeninny)", @"by Yinglu Zou (snakeninny)")];
	[label setTextColor:[UIColor colorWithRed:0.3f green:0.34f blue:0.42f alpha:1.0f]];
	[label setShadowColor:[UIColor whiteColor]];
	[label setShadowOffset:CGSizeMake(1.0f, 1.0f)];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setFont:[UIFont systemFontOfSize:16.0f]];
	CGSize size = [label.text sizeWithFont:label.font];
	[label setFrame:CGRectMake((appFrame.size.width - size.width) / 2.0f, view.bounds.size.height - size.height - 12.0f, size.width, size.height)];
	[view addSubview:label];
	[label release];
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

- (void)updateDatabase
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:SETTINGS] && [[NSDictionary dictionaryWithContentsOfFile:SETTINGS] count] != 15)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"It seems that you have installed SMSNinja before. To activate version 1.5, SMSNinja have to convert settings files to the latest suitable format. Settings files are stored in \"/var/mobile/Library/SMSNinja\", it's highly recommended that you make a backup of the files first. Are you sure to convert now?", @"It seems that you have installed SMSNinja before. To activate version 1.5, SMSNinja have to convert settings files to the latest suitable format. Settings files are stored in \"/var/mobile/Library/SMSNinja\", it's highly recommended that you make a backup of the files first. Are you sure to convert now?") delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", @"Yes") otherButtonTitles:NSLocalizedString(@"One second!", @"One second!"), nil];
		[alertView show];
		[alertView release];
	}
	else dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), CreateDatabase);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:SETTINGS error:nil];
		[fileManager copyItemAtPath:@"/Applications/SMSNinja.app/smsninja.plist" toPath:SETTINGS error:nil];
        __block SNMainViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sqlite3 *database;
            if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
            {
                // blacklist
                NSString *sql = @"alter table blacklist add forward text";
                int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update blacklist set forward = ''";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"alter table blacklist add number text";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update blacklist set number = ''";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                // whitelist
                sql = @"alter table whitelist add forward text";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update whitelist set forward = ''";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"alter table whitelist add number text";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update whitelist set number = ''";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                // privatelist
                sql = @"alter table privatelist add forward text";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update privatelist set forward = ''";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"alter table privatelist add number text";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update privatelist set number = ''";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                // blockedcall
                sql = @"create table if not exists blockedcalltemp (id text primary key, content text, name text, number text, time text, pictures text, read text)";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"insert into blockedcalltemp (id, content, name, number, time, read) select id, content, name, number, time, read from blockedcall";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update blockedcalltemp set pictures = '0'";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"drop table if exists blockedcall";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"alter table blockedcalltemp rename to blockedcall";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                // privatecall
                sql = @"create table if not exists privatecalltemp (id text primary key, content text, name text, number text, time text, pictures text, read text)";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"insert into privatecalltemp (id, content, name, number, time) select id, content, name, number, time from privatecall";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update privatecalltemp set pictures = '0', read = '1'";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"drop table if exists privatecall";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"alter table privatecalltemp rename to privatecall";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                // blockedsms
                sql = @"create table if not exists blockedsmstemp (id text primary key, content text, name text, number text, time text, pictures text, read text)";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"insert into blockedsmstemp (id, content, name, number, time, read) select id, content, name, number, time, read from blockedsms";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update blockedsmstemp set pictures = '0'";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"drop table if exists blockedsms";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"alter table blockedsmstemp rename to blockedsms";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                // privatesms
                sql = @"create table if not exists privatesmstemp (id text primary key, content text, name text, number text, time text, pictures text, read text)";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"insert into privatesmstemp (id, content, name, number, time) select id, content, name, number, time from privatesms";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"update privatesmstemp set pictures = '0', read = '1'";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"drop table if exists privatesms";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sql = @"alter table privatesmstemp rename to privatesms";
                execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                
                sqlite3_close(database);
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDir;
            
            if (!([fileManager fileExistsAtPath:PICTURES isDirectory:&isDir] && isDir))
                [fileManager createDirectoryAtPath:PICTURES withIntermediateDirectories:YES attributes:nil error:nil];
            
            if (!([fileManager fileExistsAtPath:PRIVATEPICTURES isDirectory:&isDir] && isDir))
                [fileManager createDirectoryAtPath:PRIVATEPICTURES withIntermediateDirectories:YES attributes:nil error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        });
    }
}

- (void)gotoSettingsView
{
	SNSettingsViewController *settingsViewControllerClass = [[SNSettingsViewController alloc] init];
	[self.navigationController pushViewController:settingsViewControllerClass animated:YES];
	[settingsViewControllerClass release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([self.fake boolValue]) return 2;
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 1) return 2;
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
    
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-fucking-cell"] autorelease];
        
		switch (indexPath.section)
		{
			case 0:
            {
                cell.textLabel.text = NSLocalizedString(@"SMSNinja", @"SMSNinja");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [appSwitch setAlternateColors:YES];
                cell.accessoryView = appSwitch;
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
                appSwitch.on = [[dictionary objectForKey:@"appIsOn"] boolValue];
                [appSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];
                break;
            }
			case 1:
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                switch (indexPath.row)
                {
                    case 0:
                        cell.textLabel.text = NSLocalizedString(@"Blocked Info", @"Blocked Info");
                        break;
                    case 1:
                        cell.textLabel.text = NSLocalizedString(@"Black & Whitelist", @"Black & Whitelist");
                        break;
                }
                break;
            }
			case 2:
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = NSLocalizedString(@"Private Zone", @"Private Zone");
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
                SNBlockedMessageHistoryViewController *blockedMessageHistoryViewController = [[SNBlockedMessageHistoryViewController alloc] init];
                [self.navigationController pushViewController:blockedMessageHistoryViewController animated:YES];
                [blockedMessageHistoryViewController release];
                break;
            }
			case 1:
            {
                SNBlacklistViewController *blacklistViewController = [[SNBlacklistViewController alloc] init];
                [self.navigationController pushViewController:blacklistViewController animated:YES];
                [blacklistViewController release];
                break;
            }
		}
	}
	else if (indexPath.section == 2)
	{
		SNPrivateViewController *privateViewController = [[SNPrivateViewController alloc] init];
		[self.navigationController pushViewController:privateViewController animated:YES];
		[privateViewController release];
	}
}

- (void)saveSettings
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
	[dictionary setObject:[NSNumber numberWithBool:appSwitch.on] forKey:@"appIsOn"];
	[dictionary writeToFile:SETTINGS atomically:YES];
}

- (void)gotoReadMeView
{
	SNReadMeViewController *readMeViewController = [[SNReadMeViewController alloc] init];
	readMeViewController.fake = self.fake;
	[self.navigationController pushViewController:readMeViewController animated:YES];
	[readMeViewController release];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
	NSMutableArray *labelArray = [NSMutableArray arrayWithCapacity:5];
	for (UIView *view in alertView.subviews)
	{
		if ([view isKindOfClass:[UILabel class]])
			[labelArray addObject:view];
	}
    
	for (UILabel *label in labelArray)
		if ([[label text] length] > 20)
			label.textAlignment = NSTextAlignmentLeft;
}
@end
