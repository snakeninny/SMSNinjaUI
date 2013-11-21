#import "SNPrivateMessageHistoryViewController.h"
#import "PrivateCallHistoryViewController.h"
#import <sqlite3.h>
#import "CallHistoryViewController.h"
#import "PrivateViewController.h"
#import "SettingsViewController.h"
#import "CPDistributedMessagingCenter.h"
#import <objc/runtime.h>
#import "PictureViewController.h"

#define DOCUMENT @"/var/mobile/Library/SMSNinja"
#define SETTINGS [DOCUMENT stringByAppendingString:@"/smsninja.plist"]
#define DATABASE [DOCUMENT stringByAppendingString:@"/smsninja.db"]
#define PRIVATEPICTURES [DOCUMENT stringByAppendingString:@"/PrivatePictures/"]

@implementation SNPrivateMessageHistoryViewController
- (PrivateSMSHistoryViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStylePlain]))
	{
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear") style:UIBarButtonItemStylePlain target:self action:@selector(deleteAll)] autorelease];

		UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101];
		[backButton addTarget:self action:@selector(gotoPrivateViewController) forControlEvents:UIControlEventTouchUpInside];
		[backButton setTitle:NSLocalizedString(@"Private Zone", @"Private Zone") forState:UIControlStateNormal];
		UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
		self.navigationItem.leftBarButtonItem = [backItem autorelease];

		[self initDB];
	}
	return self;
}

- (void)initDB
{
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"SMS", @"SMS"), NSLocalizedString(@"Call", @"Call"), nil]];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0.0f, 0.0f, 100.0f, 30.0f);
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];

	[idArray release];
	[nameArray release];
	[contentArray release];
	[timeArray release];
	[numberArray release];
	[picturesArray release];

	idArray = [[NSMutableArray alloc] init];
	nameArray = [[NSMutableArray alloc] init];
	contentArray = [[NSMutableArray alloc] init];
	timeArray = [[NSMutableArray alloc] init];
	numberArray = [[NSMutableArray alloc] init];
	picturesArray = [[NSMutableArray alloc] init];

	sqlite3 *database;
	sqlite3_stmt *statement;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = @"select name, content, time, number, id, pictures from privatesms order by (cast(id as integer)) desc";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				char *name = (char *)sqlite3_column_text(statement, 0);
				[nameArray addObject:name ? [NSString stringWithUTF8String:name] : @""];

				char *content = (char *)sqlite3_column_text(statement, 1);
				NSString *contentString = content ? [NSString stringWithUTF8String:content] : @""; 
				[contentArray addObject:contentString];

				char *time = (char *)sqlite3_column_text(statement, 2);
				[timeArray addObject:time ? [NSString stringWithUTF8String:time] : @""];;

				char *number = (char *)sqlite3_column_text(statement, 3);
				[numberArray addObject:number ? [NSString stringWithUTF8String:number] : @""];

				char *identifier = (char *)sqlite3_column_text(statement, 4);
				[idArray addObject:identifier ? [NSString stringWithUTF8String:identifier] : @""];

				char *pictures = (char *)sqlite3_column_text(statement, 5);
				[picturesArray addObject:pictures ? [NSString stringWithUTF8String:pictures] : @""];
			}
			sqlite3_finalize(statement);
		}
		else NSLog(@"SNERROR: %s", [sql UTF8String]);

		sqlite3_close(database);
	}
}

- (void)deleteAll
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SMSNinja", @"SMSNinja") message:NSLocalizedString(@"Are you sure to clear all message history?", @"Are you sure to clear all message history?") delegate:self cancelButtonTitle:NSLocalizedString(@"Forget that!", @"Forget that!") otherButtonTitles:NSLocalizedString(@"Go ahead!", @"Go ahead!"), nil];
	alertView.tag = 1;
	[alertView show];
	[alertView release];
}

- (void)segmentAction:(id)sender
{
	switch ([sender selectedSegmentIndex])
	{
		case 0:
			{
				PrivateSMSHistoryViewController *privateSMSHistoryViewControllerClass = [[PrivateSMSHistoryViewController alloc] init];
				[self.navigationController pushViewController:privateSMSHistoryViewControllerClass animated:NO];
				[privateSMSHistoryViewControllerClass release];
				break;
			}
		case 1:
			{
				PrivateCallHistoryViewController *privateCallHistoryViewControllerClass = [[PrivateCallHistoryViewController alloc] init];
				[self.navigationController pushViewController:privateCallHistoryViewControllerClass animated:NO];
				[privateCallHistoryViewControllerClass release];
				break;
			}
	}
}

- (void)loadView
{
	CPDistributedMessagingCenter *messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.naken.smsninjaspringboard"];
	[messagingCenter sendMessageName:@"HideYellowSquare" userInfo:nil];
	[messagingCenter sendMessageName:@"HideColon" userInfo:nil];

	[super loadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [idArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];

	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-fucking-cell"] autorelease];

		cell.accessoryType = [[picturesArray objectAtIndex:indexPath.row] intValue] == 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryDetailDisclosureButton;

		CGRect nameLabelRect = CGRectMake(5.0f, 5.0f, 150.0f, 17.0f);
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
		nameLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1)
			nameLabel.minimumFontSize = 8.0f;
		else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1)
			nameLabel.minimumScaleFactor = 8.0f;

		nameLabel.adjustsFontSizeToFitWidth = YES;
		nameLabel.tag = 1;
		[cell.contentView addSubview:nameLabel];
		[nameLabel release];

		CGRect timeLabelRect = CGRectMake(155.0f, 5.0f, 150.0f, 17.0f);
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeLabelRect];
		timeLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1)
			timeLabel.minimumFontSize = 8.0f;
		else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1)
			timeLabel.minimumScaleFactor = 8.0f;

		timeLabel.adjustsFontSizeToFitWidth = YES;
		timeLabel.tag = 2;
		[cell.contentView addSubview:timeLabel];
		[timeLabel release];

		UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 23.0f, 295.0f, 0.0f)];
		contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
		contentLabel.tag = 3;
		contentLabel.numberOfLines = 0;
		contentLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		CGSize expectedLabelSize = [[contentArray objectAtIndex:indexPath.row] sizeWithFont:contentLabel.font constrainedToSize:CGSizeMake(295.0f, 6666.0f) lineBreakMode:contentLabel.lineBreakMode];
		CGRect newFrame = contentLabel.frame;
		newFrame.size.height = expectedLabelSize.height;
		contentLabel.frame = newFrame;
		[cell.contentView addSubview:contentLabel];
		[contentLabel release];
	}

	UILabel *nameTemp = (UILabel *)[cell viewWithTag:1];
	nameTemp.text = [[nameArray objectAtIndex:indexPath.row] length] != 0 ? [nameArray objectAtIndex:indexPath.row] : [numberArray objectAtIndex:indexPath.row];
	UILabel *timeTemp = (UILabel *)[cell viewWithTag:2];
	timeTemp.text = [timeArray objectAtIndex:indexPath.row];
	UILabel *contentTemp = (UILabel *)[cell viewWithTag:3];
	contentTemp.text = [contentArray objectAtIndex:indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	sqlite3 *database;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"delete from privatesms where number = '%@' and name = '%@' and time = '%@' and content = '%@' and id = '%@' and pictures = '%@'", [numberArray objectAtIndex:indexPath.row], [[nameArray objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [timeArray objectAtIndex:indexPath.row], [[contentArray objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], [idArray objectAtIndex:indexPath.row], [picturesArray objectAtIndex:indexPath.row]];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
			NSLog(@"SNERROR: %s", [sql UTF8String]);
		sqlite3_close(database);
	}

	for (int i = 0; i < [[picturesArray objectAtIndex:indexPath.row] intValue]; i++)
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:[[PRIVATEPICTURES stringByAppendingString:[idArray objectAtIndex:indexPath.row]] stringByAppendingFormat:@"-%d.png", i] error:nil];
		[fileManager removeItemAtPath:[[PRIVATEPICTURES stringByAppendingString:[idArray objectAtIndex:indexPath.row]] stringByAppendingFormat:@"-%d.jpg", i] error:nil];
	}

	[idArray removeObjectAtIndex:indexPath.row];
	[nameArray removeObjectAtIndex:indexPath.row];
	[contentArray removeObjectAtIndex:indexPath.row];
	[timeArray removeObjectAtIndex:indexPath.row];
	[numberArray removeObjectAtIndex:indexPath.row];
	[picturesArray removeObjectAtIndex:indexPath.row];

	[tableView beginUpdates];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];

	SettingsViewController *settings = [[SettingsViewController alloc] init];
	[settings updateBadge];
	[settings release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	chosenRow = indexPath.row;

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	[pasteboard setValue:[contentArray objectAtIndex:chosenRow] forPasteboardType:@"public.utf8-plain-text"];

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[nameArray objectAtIndex:chosenRow] length] != 0 ? [nameArray objectAtIndex:chosenRow] : [numberArray objectAtIndex:chosenRow] message:[contentArray objectAtIndex:chosenRow] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:NSLocalizedString(@"Call", @"Call"), NSLocalizedString(@"SMS", @"SMS"), nil];
	alertView.tag = 2;
	[alertView show];
	[alertView release];

	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];

	SettingsViewController *settingsViewControllerClass = [[SettingsViewController alloc] init];
	[settingsViewControllerClass updateBadge];
	[settingsViewControllerClass release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	PictureViewController *picturesViewClass = [[PictureViewController alloc] init];
	picturesViewClass.flag = @"private";
	picturesViewClass.idString = [idArray objectAtIndex:indexPath.row];
	picturesViewClass->picturesCount = [[picturesArray objectAtIndex:indexPath.row] intValue];
	[self.navigationController pushViewController:picturesViewClass animated:YES];
	[picturesViewClass release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"SMS", @"SMS");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize cellSize = [[contentArray objectAtIndex:indexPath.row] sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(295.0f, 6666.0f) lineBreakMode:NSLineBreakByWordWrapping];
	return cellSize.height + 22.0f + 6.0f;
}

- (void)gotoPrivateViewController
{
	for (UIViewController *viewController in self.navigationController.viewControllers)
	{
		if ([viewController isKindOfClass:[PrivateViewController class]])
		{
			PrivateViewController *privateViewClass = (PrivateViewController *)viewController;
			[self.navigationController popToViewController:privateViewClass animated:YES];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	sqlite3 *database;

	if (alertView.tag == 1)
	{
		if (buttonIndex == 1)
		{
			if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
			{
				NSString *sql = [NSString stringWithFormat:@"delete from privatesms"];
				if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
					NSLog(@"SNERROR: %s", [sql UTF8String]);
				sqlite3_close(database);
			}

			[idArray removeAllObjects];
			[nameArray removeAllObjects];
			[contentArray removeAllObjects];
			[timeArray removeAllObjects];
			[numberArray removeAllObjects];
			[picturesArray removeAllObjects];

			[self.tableView reloadData];

			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:PRIVATEPICTURES error:nil];
			for (NSString *fileName in fileNames)
				[fileManager removeItemAtPath:[(NSString *)PRIVATEPICTURES stringByAppendingString:fileName] error:nil];
		}
	}
	else if (alertView.tag == 2)
	{
		if (buttonIndex == 1)
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [numberArray objectAtIndex:chosenRow]]]];
		}
		else if (buttonIndex == 2)
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", [numberArray objectAtIndex:chosenRow]]]];
		}
	}

	SettingsViewController *settings = [[SettingsViewController alloc] init];
	[settings updateBadge];
	[settings release];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{  
	if (alertView.tag == 2)
	{
		UILabel* label = (UILabel *)[alertView.subviews objectAtIndex:2];
		label.textAlignment = NSTextAlignmentLeft;
	}
}

- (void)dealloc
{
	[idArray release];
	idArray = nil;

	[nameArray release];
	nameArray = nil;

	[contentArray release];
	contentArray = nil;

	[timeArray release];
	timeArray = nil;

	[numberArray release];
	numberArray = nil;

	[picturesArray release];
	picturesArray = nil;

	[super dealloc];
}
@end

