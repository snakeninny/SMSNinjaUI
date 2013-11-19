#import "SNSystemCallHistoryViewController.h"
#import "SNBlacklistViewController.h"
#import "SNWhitelistViewController.h"
#import "SNPrivatelistViewController.h"
#import "SNNumberViewController.h"
#import "SMSNinja-private.h"
#import <objc/runtime.h>
#import <sqlite3.h>

#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"
#define CALLHISTORY @"/var/wireless/Library/CallHistory/call_history.db"

@implementation SNSystemCallHistoryViewController

@synthesize flag;

- (void)dealloc
{
	[numberArray release];
	numberArray = nil;
    
	[nameArray release];
	nameArray = nil;
    
	[timeArray release];
	timeArray = nil;
    
	[typeArray release];
	typeArray = nil;
    
	[keywordSet release];
	keywordSet = nil;
    
	[flag release];
	flag = nil;
    
	[super dealloc];
}

- (void)gotoList
{
    id viewController = [self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] - 2)];
    [viewController loadDatabaseSegment];
    [((UITableViewController *)viewController).tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initializeAllArrays
{
	CPDistributedMessagingCenter *messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.naken.smsninjaspringboard"];
	NSDictionary *reply = [messagingCenter sendMessageAndReceiveReplyName:@"GetSystemCallHistory" userInfo:nil];
	numberArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"numberArray"]];
	nameArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"nameArray"]];
	timeArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"timeArray"]];
	typeArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"typeArray"]];
	keywordSet = [[NSMutableSet alloc] initWithCapacity:600];
    
	sqlite3 *database;
	sqlite3_stmt *statement;
	int openResult = sqlite3_open([DATABASE UTF8String], &database);
	if (openResult == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select keyword from %@list", self.flag];
		int prepareResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
		if (prepareResult == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				char *keyword = (char *)sqlite3_column_text(statement, 0);
				[keywordSet addObject:keyword ? [NSString stringWithUTF8String:keyword] : @""];
			}
			sqlite3_finalize(statement);
		}
		else NSLog(@"SMSNinja: Failed to prepare %@, error %d", DATABASE, prepareResult);
		sqlite3_close(database);
	}
	else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
}

- (SNSystemCallHistoryViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStylePlain]))
	{
		self.title = NSLocalizedString(@"Call History", @"Call History");
		UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101];
		[backButton addTarget:self action:@selector(gotoList) forControlEvents:UIControlEventTouchUpInside];
		[backButton setTitle:NSLocalizedString(@"List", @"List") forState:UIControlStateNormal];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
		flag = [[NSString alloc] initWithString:@""];
        
		[self initializeAllArrays];
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [numberArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];
    
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 2.0f, (cell.contentView.bounds.size.width - 20.0f) / 2.0f, (cell.contentView.bounds.size.height - 4.0f) / 2.0f)];
	nameLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) nameLabel.minimumFontSize = 8.0f;
	else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) nameLabel.minimumScaleFactor = 8.0f;
	nameLabel.adjustsFontSizeToFitWidth = YES;
	nameLabel.text = [[nameArray objectAtIndex:indexPath.row] length] != 0 ? [nameArray objectAtIndex:indexPath.row] : [numberArray objectAtIndex:indexPath.row];
	[cell.contentView addSubview:nameLabel];
	[nameLabel release];
    
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.bounds.size.width, nameLabel.frame.origin.y, nameLabel.bounds.size.width, nameLabel.bounds.size.height)];
	timeLabel.font = nameLabel.font;
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) timeLabel.minimumFontSize = nameLabel.minimumFontSize;
	else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) timeLabel.minimumScaleFactor = nameLabel.minimumScaleFactor;
	timeLabel.adjustsFontSizeToFitWidth = nameLabel.adjustsFontSizeToFitWidth;
	timeLabel.text = [timeArray objectAtIndex:indexPath.row];
	timeLabel.textColor = nameLabel.textColor;
	[cell.contentView addSubview:timeLabel];
	[timeLabel release];
    
	UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.bounds.size.height, nameLabel.bounds.size.width, nameLabel.bounds.size.height)];
	numberLabel.font = nameLabel.font;
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) numberLabel.minimumFontSize = nameLabel.minimumFontSize;
	else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) numberLabel.minimumScaleFactor = nameLabel.minimumScaleFactor;
	numberLabel.adjustsFontSizeToFitWidth = nameLabel.adjustsFontSizeToFitWidth;
	numberLabel.text = [numberArray objectAtIndex:indexPath.row];
	numberLabel.textColor = nameLabel.textColor;
	[cell.contentView addSubview:numberLabel];
	[numberLabel release];
    
	UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x, numberLabel.frame.origin.y, nameLabel.bounds.size.width, nameLabel.bounds.size.height)];
	typeLabel.font = nameLabel.font;
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) typeLabel.minimumFontSize = nameLabel.minimumFontSize;
	else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) typeLabel.minimumScaleFactor = nameLabel.minimumScaleFactor;
	typeLabel.adjustsFontSizeToFitWidth = nameLabel.adjustsFontSizeToFitWidth;
	typeLabel.text = [typeArray objectAtIndex:indexPath.row];
	typeLabel.textColor = nameLabel.textColor;
	[cell.contentView addSubview:typeLabel];
	[numberLabel release];
    
	if ([keywordSet containsObject:numberLabel.text]) cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else cell.accessoryType = UITableViewCellAccessoryNone;
    
	return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	sqlite3 *database;
    
	if (actionSheet.tag == 1) // single
	{
		switch (buttonIndex)
		{
			case 0: // OFF
				if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
				{
					NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '0')", self.flag, self.chosenNumber];
                    
					if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
						NSLog(@"SNERROR: %s", [sql UTF8String]);
					sqlite3_close(database);
				}
				break;
			case 1: // ON
				if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
				{
					NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '1')", self.flag, self.chosenNumber];
                    
					if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
						NSLog(@"SNERROR: %s", [sql UTF8String]);
					sqlite3_close(database);
				}
				break;
		}
	}
	else if (actionSheet.tag == 2) // all
	{
		if (![self.flag isEqualToString:@"white"])
		{
			switch(buttonIndex)
			{
				case 0: // OFF
                {
                    for (NSString *number in numberArray)
                    {
                        if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
                        {
                            NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '0')", self.flag, number];
                            
                            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
                                NSLog(@"SNERROR: %s", [sql UTF8String]);
                            sqlite3_close(database);
                        }
                    }
                    break;
                }
				case 1: // ON
                {
                    for (NSString *number in numberArray)
                    {
                        if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
                        {
                            NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '1')", self.flag, number];
                            
                            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
                                NSLog(@"SNERROR: %s", [sql UTF8String]);
                            sqlite3_close(database);
                        }
                    }
                    break;
                }
				case 2: // cancel
                {
                    for (NSString *number in numberArray)
                    {
                        if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
                        {
                            NSString *sql = [NSString stringWithFormat:@"delete from %@list where keyword = '%@'", self.flag, number];
                            
                            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
                                NSLog(@"SNERROR: %s", [sql UTF8String]);
                            sqlite3_close(database);
                        }
                    }
                    break;
                }
			}
		}
		else
		{
			switch(buttonIndex)
			{
				case 0: // OFF
                {
                    for (NSString *number in numberArray)
                    {
                        if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
                        {
                            NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '0')", self.flag, number];
                            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
                                NSLog(@"SNERROR: %s", [sql UTF8String]);
                            sqlite3_close(database);
                        }
                    }
                    break;
                }
				case 1: // cancel
                {
                    for (NSString *number in numberArray)
                    {
                        if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
                        {
                            NSString *sql = [NSString stringWithFormat:@"delete from %@list where keyword = '%@'", self.flag, number];
                            
                            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
                                NSLog(@"SNERROR: %s", [sql UTF8String]);
                            sqlite3_close(database);
                        }
                    }
                    break;
                }
			}
		}
		[self gotoList];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.editing)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        SNNumberViewController *numberViewController = [[SNNumberViewController alloc] init];
        numberViewController.flag = self.flag;
        numberViewController.nameString = [nameArray objectAtIndex:indexPath.row];
        numberViewController.keywordString = [numberArray objectAtIndex:indexPath.row];
        numberViewController.phoneString = @"1";
        numberViewController.smsString = @"1";
        numberViewController.replyString = @"0";
        numberViewController.messageString = @"";
        numberViewController.forwardString = @"0";
        numberViewController.numberString = @"";
        numberViewController.soundString = @"1";
        [self.navigationController pushViewController:numberViewController animated:YES];
        [numberViewController release];
    }
    else
    {
        chosenRow = indexPath.row;
        if (![self.flag isEqualToString:@"white"])
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Turn off the beep", @"Turn off the beep"), NSLocalizedString(@"Turn on the beep", @"Turn on the beep"), nil];
            [actionSheet showFromToolbar:self.navigationController.toolbar];
            [actionSheet release];
        }
        else
        {
            __block SNSystemCallHistoryViewController *weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                           {
                               sqlite3 *database;
                               int openResult = sqlite3_open([DATABASE UTF8String], &database);
                               if (openResult == SQLITE_OK)
                               {
                                   NSString *sql = [NSString stringWithFormat:@"insert or replace into whitelist (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '0')", [weakSelf->numberArray objectAtIndex:weakSelf->chosenRow]];
                                   int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                                   if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                                   sqlite3_close(database);
                               }
                               else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
                           });
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block int index = indexPath.row;
    __block SNSystemCallHistoryViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       sqlite3 *database;
                       int openResult = sqlite3_open([DATABASE UTF8String], &database);
                       if (openResult == SQLITE_OK)
                       {
                           NSString *sql = [NSString stringWithFormat:@"delete from %@list where keyword = '%@'", weakSelf.flag, [weakSelf->numberArray objectAtIndex:index]];
                           int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                           if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                           sqlite3_close(database);
                       }
                       else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
                   });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
}

- (void)selectAll:(UIBarButtonItem *)buttonItem
{
	if ([buttonItem.title isEqualToString:NSLocalizedString(@"All", @"All")])
	{
		buttonItem.title = NSLocalizedString(@"None", @"None");
		for (UITableViewCell *cell in [self.tableView visibleCells])
			cell.selected = YES;
        [bulkSet removeAllObjects];
        for (int i = 0; i < [idArray count]; i++)
            [bulkSet addObject:[NSIndexPath indexPathForRow:i inSection:0]];
	}
	else if ([buttonItem.title isEqualToString:NSLocalizedString(@"None", @"None")])
	{
		buttonItem.title = NSLocalizedString(@"All", @"All");
		for (UITableViewCell *cell in [self.tableView visibleCells])
			cell.selected = NO;
        [bulkSet removeAllObjects];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	[bulkSet removeAllObjects];
	self.navigationController.toolbarHidden = !editing;
	if (editing)
	{
		for (UITableViewCell *cell in [self.tableView visibleCells])
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"All", @"All") style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)] autorelease];
	}
	else
	{
		for (UITableViewCell *cell in [self.tableView visibleCells])
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101];
		[backButton addTarget:self action:@selector(gotoMainView) forControlEvents:UIControlEventTouchUpInside];
		[backButton setTitle:NSLocalizedString(@"SMSNinja", @"SMSNinja") forState:UIControlStateNormal];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
	}
	[super setEditing:editing animated:animate];
}
@end
