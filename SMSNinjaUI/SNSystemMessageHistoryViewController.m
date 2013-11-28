#import "SNSystemMessageHistoryViewController.h"
#import "SNNumberViewController.h"
#import "SNWhitelistViewController.h"
#import "SNBlacklistViewController.h"
#import "SNPrivatelistViewController.h"
#import <objc/runtime.h>
#import <sqlite3.h>

#ifndef SMSNinjaDebug
#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"
#else
#define SETTINGS @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/0C9D35FB-B626-42B7-AAE9-45F6F537890B/Documents/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/0C9D35FB-B626-42B7-AAE9-45F6F537890B/Documents/var/mobile/Library/SMSNinja/smsninja.db"
#endif

@implementation SNSystemMessageHistoryViewController

@synthesize flag;

- (void)dealloc
{
    [numberArray release];
    numberArray = nil;
    
    [nameArray release];
    nameArray = nil;
    
    [timeArray release];
    timeArray = nil;
    
    [contentArray release];
    contentArray = nil;
    
    [keywordSet release];
    keywordSet = nil;
    
    [flag release];
    flag = nil;
    
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    id viewController = [self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] - 1)];
    if ([viewController isKindOfClass:[SNNumberViewController class]]) return;
    [((UITableViewController *)viewController).tableView reloadData];
}

- (void)initializeAllArrays
{
    CPDistributedMessagingCenter *messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.naken.smsninjaspringboard"];
    NSDictionary *reply = [messagingCenter sendMessageAndReceiveReplyName:@"GetSystemMessageHistory" userInfo:nil];
    numberArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"numberArray"]];
    nameArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"nameArray"]];
    timeArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"timeArray"]];
    contentArray = [[NSMutableArray alloc] initWithArray:[reply objectForKey:@"contentArray"]];
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

- (SNSystemMessageHistoryViewController *)init
{
    if ((self = [super initWithStyle:UITableViewStylePlain]))
    {
        self.title = NSLocalizedString(@"Message History", @"Message History");
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
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
    for (UIView *subview in [cell.contentView subviews])
        [subview removeFromSuperview];
    cell.textLabel.text = nil;
    cell.accessoryView = nil;
    
    UITableViewCell *defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default-cell"];
    int defaultCellHeight = defaultCell.bounds.size.height;
    int defaultCellWidth = defaultCell.bounds.size.width;
    [defaultCell release];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 2.0f, (defaultCellWidth - 36.0f) / 2.0f, (defaultCellHeight - 4.0f) / 2.0f)];
    nameLabel.tag = 1;
    nameLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) nameLabel.minimumFontSize = 8.0f;
    else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) nameLabel.minimumScaleFactor = 8.0f;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.text = [[nameArray objectAtIndex:indexPath.row] length] != 0 ? [nameArray objectAtIndex:indexPath.row] : [numberArray objectAtIndex:indexPath.row];
    [cell.contentView addSubview:nameLabel];
    [nameLabel release];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.bounds.size.width, nameLabel.frame.origin.y, nameLabel.bounds.size.width, nameLabel.bounds.size.height)];
    timeLabel.tag = 2;
    timeLabel.font = nameLabel.font;
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1)
    {
        timeLabel.minimumFontSize = nameLabel.minimumFontSize;
        timeLabel.textAlignment = UITextAlignmentRight;
    }
	else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1)
    {
        timeLabel.minimumScaleFactor = nameLabel.minimumScaleFactor;
        timeLabel.textAlignment = NSTextAlignmentRight;
    }
    timeLabel.adjustsFontSizeToFitWidth = nameLabel.adjustsFontSizeToFitWidth;
    timeLabel.text = [timeArray objectAtIndex:indexPath.row];
    timeLabel.textColor = nameLabel.textColor;
    [cell.contentView addSubview:timeLabel];
    [timeLabel release];
    
	UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.bounds.size.height, nameLabel.bounds.size.width + timeLabel.bounds.size.width, nameLabel.bounds.size.height)];
	contentLabel.tag = 3;
	contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
	contentLabel.numberOfLines = 0;
	contentLabel.font = nameLabel.font;
	contentLabel.text = [contentArray objectAtIndex:indexPath.row];
	CGSize expectedLabelSize = [contentLabel.text sizeWithFont:contentLabel.font constrainedToSize:CGSizeMake(contentLabel.bounds.size.width, contentLabel.bounds.size.height * 60.0f) lineBreakMode:contentLabel.lineBreakMode];
	CGRect newFrame = contentLabel.frame;
	newFrame.size.height = expectedLabelSize.height;
	contentLabel.frame = newFrame;
	contentLabel.textColor = nameLabel.textColor;
	[cell.contentView addSubview:contentLabel];
	[contentLabel release];
    
    if ([keywordSet containsObject:[numberArray objectAtIndex:indexPath.row]]) cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default-cell"] autorelease];
    return (cell.contentView.bounds.size.height - 4.0f) / 2.0f + [[contentArray objectAtIndex:indexPath.row] sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake((cell.contentView.bounds.size.width - 36.0f), (cell.contentView.bounds.size.height - 4.0f) / 2.0f * 60.0f) lineBreakMode:NSLineBreakByWordWrapping].height + 4.0f;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) // single
    {
        if (buttonIndex == 2) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:buttonIndex inSection:0]].selected = NO;
        
        __block NSInteger index = buttonIndex;
        __block SNSystemMessageHistoryViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           sqlite3 *database;
                           int openResult = sqlite3_open([DATABASE UTF8String], &database);
                           if (openResult == SQLITE_OK)
                           {
                               NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '%d')", weakSelf.flag, [weakSelf->numberArray objectAtIndex:weakSelf->chosenRow], index];
                               int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                               if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                               sqlite3_close(database);
                           }
                           else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
                       });
    }
    else if (actionSheet.tag == 2) // all
    {
        if (buttonIndex == 2)
        {
            for (int i = 0; i < [numberArray count]; i++)
                [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].selected = NO;
        }
        
        __block NSInteger index = buttonIndex;
        __block SNSystemMessageHistoryViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           sqlite3 *database;
                           int openResult = sqlite3_open([DATABASE UTF8String], &database);
                           if (openResult == SQLITE_OK)
                           {
                               for (NSString *number in weakSelf->numberArray)
                               {
                                   NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '%d')", weakSelf.flag, number, index];
                                   int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                                   if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                               }
                               sqlite3_close(database);
                           }
                           else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
                       });
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
        numberViewController.phoneAction = @"1";
        numberViewController.messageAction = @"1";
        numberViewController.replyString = @"0";
        numberViewController.messageString = @"";
        numberViewController.forwardString = @"0";
        numberViewController.numberString = @"";
        numberViewController.soundString = @"1";
        UINavigationController *navigationController = self.navigationController;
        [navigationController popViewControllerAnimated:NO];
        [navigationController pushViewController:numberViewController animated:YES];
        [numberViewController release];
    }
    else
    {
        chosenRow = indexPath.row;
        if (![self.flag isEqualToString:@"white"])
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Turn off the beep", @"Turn off the beep"), NSLocalizedString(@"Turn on the beep", @"Turn on the beep"), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            [actionSheet release];
        }
        else
        {
            SNWhitelistViewController *viewController = (SNWhitelistViewController *)[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] - 2)];
            [viewController->nameArray insertObject:@"" atIndex:0];
            [viewController->keywordArray insertObject:[self->numberArray objectAtIndex:self->chosenRow] atIndex:0];
            [viewController->typeArray insertObject:@"0" atIndex:0];
            
            sqlite3 *database;
            int openResult = sqlite3_open([DATABASE UTF8String], &database);
            if (openResult == SQLITE_OK)
            {
                NSString *sql = [NSString stringWithFormat:@"insert or replace into whitelist (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '0')", [self->numberArray objectAtIndex:self->chosenRow]];
                int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                sqlite3_close(database);
            }
            else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block int index = indexPath.row;
    __block SNSystemMessageHistoryViewController *weakSelf = self;
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
        for (int i = 0; i < [numberArray count]; i++)
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].selected = YES;
        
        if (![self.flag isEqualToString:@"white"])
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Turn off the beep", @"Turn off the beep"), NSLocalizedString(@"Turn on the beep", @"Turn on the beep"), nil];
            actionSheet.tag = 2;
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            [actionSheet release];
        }
        else
        {
            __block SNSystemMessageHistoryViewController *weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                           {
                               sqlite3 *database;
                               int openResult = sqlite3_open([DATABASE UTF8String], &database);
                               if (openResult == SQLITE_OK)
                               {
                                   for (NSString *number in weakSelf->numberArray)
                                   {
                                       NSString *sql = [NSString stringWithFormat:@"insert or replace into whitelist (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '', '1', '1', '0', '', '0', '', '0')", number];
                                       int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                                       if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                                   }
                                   sqlite3_close(database);
                               }
                               else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
                           });
        }
    }
    else if ([buttonItem.title isEqualToString:NSLocalizedString(@"None", @"None")])
    {
        buttonItem.title = NSLocalizedString(@"All", @"All");
        for (int i = 0; i < [numberArray count]; i++)
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].selected = NO;
        __block SNSystemMessageHistoryViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           sqlite3 *database;
                           int openResult = sqlite3_open([DATABASE UTF8String], &database);
                           if (openResult == SQLITE_OK)
                           {
                               for (NSString *number in weakSelf->numberArray)
                               {
                                   NSString *sql = [NSString stringWithFormat:@"delete from %@list where keyword = '%@'", weakSelf.flag, number];
                                   int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                                   if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                               }
                               sqlite3_close(database);
                           }
                           else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
                       });
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [self.navigationController setToolbarHidden:!editing animated:animate];
    if (editing)
    {
        for (UITableViewCell *cell in [self.tableView visibleCells])
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"All", @"All") style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)] autorelease] animated:animate];
    }
    else
    {
        for (UITableViewCell *cell in [self.tableView visibleCells])
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [self.navigationItem setLeftBarButtonItem:nil animated:animate];
    }
    [super setEditing:editing animated:animate];
}
@end