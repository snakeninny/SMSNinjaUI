#import "SNNumberViewController.h"
#import "SNCallActionViewController.h"
#import "SNMessageActionViewController.h"
#import "SNBlacklistViewController.h"
#import "SNWhitelistViewController.h"
#import "SNPrivatelistViewController.h"
#import "SNTextTableViewCell.h"
#import <sqlite3.h>

#ifndef SMSNinjaDebug
#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"
#else
#define SETTINGS @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/0C9D35FB-B626-42B7-AAE9-45F6F537890B/Documents/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/0C9D35FB-B626-42B7-AAE9-45F6F537890B/Documents/var/mobile/Library/SMSNinja/smsninja.db"
#endif

@implementation SNNumberViewController

@synthesize nameString;
@synthesize keywordString;
@synthesize phoneAction;
@synthesize messageAction;
@synthesize replyString;
@synthesize messageString;
@synthesize soundString;
@synthesize flag;
@synthesize forwardString;
@synthesize numberString;

- (void)dealloc
{
    [nameField release];
	nameField = nil;
    
	[nameString release];
	nameString = nil;
    
    [keywordField release];
	keywordField = nil;
    
	[keywordString release];
	keywordString = nil;
    
	[phoneAction release];
	phoneAction = nil;
    
	[messageAction release];
	messageAction = nil;
    
	[replySwitch release];
	replySwitch = nil;
    
	[replyString release];
	replyString = nil;
    
	[messageField release];
	messageField = nil;
    
	[messageString release];
	messageString = nil;
    
    [soundSwitch release];
	soundSwitch = nil;
    
	[soundString release];
	soundString = nil;
    
	[forwardString release];
	forwardString = nil;
    
	[numberString release];
	numberString = nil;
    
	[flag release];
	flag = nil;
    
    [keywordArray release];
	keywordArray = nil;
    
    [tapRecognizer release];
    tapRecognizer = nil;
    
	[super dealloc];
}

- (SNNumberViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = NSLocalizedString(@"Details", @"Details");
        
        nameField = [[UITextField alloc] initWithFrame:CGRectZero];
        keywordField = [[UITextField alloc] initWithFrame:CGRectZero];
        replySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        messageField = [[UITextField alloc] initWithFrame:CGRectZero];
        soundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        
		keywordArray = [[NSMutableArray alloc] init];
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardWithTap:)];
        tapRecognizer.delegate = self;
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
	SNTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"any-cell"] autorelease];
    for (UIView *subview in [cell.contentView subviews])
        [subview removeFromSuperview];
    cell.textLabel.text = nil;
    cell.accessoryView = nil;
    
    switch (indexPath.section)
    {
        case 0:
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                nameField.delegate = self;
                nameField.placeholder = NSLocalizedString(@"Input here", @"Input here");
                nameField.text = self.nameString;
                nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [cell.contentView addSubview:nameField];
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Number", @"Number");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                keywordField.delegate = self;
                keywordField.placeholder = NSLocalizedString(@"Input here", @"Input here");
                keywordField.text = self.keywordString;
                keywordField.clearButtonMode = UITextFieldViewModeWhileEditing;
                keywordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                [cell.contentView addSubview:keywordField];
            }
            
            break;
        case 1:
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Call", @"Call");
                NSString *detailText = @"";
                if ([self.phoneAction isEqualToString:@"1"]) detailText = NSLocalizedString(@"Disconnect", @"Disconnect");
                else if ([self.phoneAction isEqualToString:@"2"]) detailText = NSLocalizedString(@"Ignore", @"Ignore");
                else if ([self.phoneAction isEqualToString:@"3"]) detailText = NSLocalizedString(@"Let go", @"Let go");
                cell.detailTextLabel.text = detailText;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"SMS", @"SMS");
                NSString *detailText = @"";
                if ([self.messageAction isEqualToString:@"1"]) detailText = [detailText stringByAppendingString:NSLocalizedString(@"Block", @"Block")];
                if ([self.forwardString isEqualToString:@"1"]) detailText = [detailText stringByAppendingString:NSLocalizedString(@", Forward", @", Forward")];
                if ([detailText hasPrefix:@", "]) detailText = [detailText substringFromIndex:2];
                cell.detailTextLabel.text = detailText;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            break;
        case 2:
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Reply", @"Reply");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = replySwitch;
                replySwitch.on = [self.replyString isEqualToString:@"0"] ? NO : YES;
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"With", @"With");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                messageField.delegate = self;
                messageField.text = self.messageString;
                messageField.clearButtonMode = UITextFieldViewModeWhileEditing;
                messageField.placeholder = NSLocalizedString(@"Message here", @"Message here");
                [cell.contentView addSubview:messageField];
            }
            
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Beep", @"Beep");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryView = soundSwitch;
            soundSwitch.on = [self.soundString isEqualToString:@"0"] ? NO : YES;
            
            break;
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (indexPath.section == 1)
	{
		switch (indexPath.row)
		{
			case 0:
            {
                SNCallActionViewController *callActionViewController = [[SNCallActionViewController alloc] init];
                callActionViewController.phoneAction = self.phoneAction;
                callActionViewController.flag = self.flag;
                [self.navigationController pushViewController:callActionViewController animated:YES];
                [callActionViewController release];
                break;
            }
			case 1:
            {
                SNMessageActionViewController *messageActionViewController = [[SNMessageActionViewController alloc] init];
                messageActionViewController.messageAction = self.messageAction;
                messageActionViewController.forwardString = self.forwardString;
                messageActionViewController.numberString = self.numberString;
                [self.navigationController pushViewController:messageActionViewController animated:YES];
                [messageActionViewController release];
                break;
            }
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.nameString = nil;
	self.keywordString = nil;
	self.replyString = nil;
	self.messageString = nil;
	self.soundString = nil;
    
	self.nameString = nameField.text ? nameField.text : @"";
	self.keywordString = keywordField.text ? keywordField.text : @"";
	self.replyString = replySwitch.on ? @"1" : @"0";
	self.messageString = messageField.text ? messageField.text : @"";
	self.soundString = soundSwitch.on ? @"1" : @"0";
    
	NSString *tempString = keywordField.text ? keywordField.text : @"";
	NSRange range = [tempString rangeOfString:@" "];
    [keywordArray removeAllObjects];
	while (range.location != NSNotFound)
	{
		if ([[tempString substringToIndex:range.location] length] != 0)
			[keywordArray addObject:[tempString substringToIndex:range.location]];
		tempString = [tempString substringFromIndex:range.location + 1];
		range = [tempString rangeOfString:@" "];
	}
	if ([tempString length] != 0)
		[keywordArray addObject:tempString];
    
    id viewController = [self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] - 1)];
    if ([viewController isKindOfClass:[SNCallActionViewController class]] || [viewController isKindOfClass:[SNMessageActionViewController class]]) return;
    
    __block SNNumberViewController *weakSelf = self;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       sqlite3 *database;
                       int openResult = sqlite3_open([DATABASE UTF8String], &database);
                       if (openResult == SQLITE_OK)
                       {
                           NSString *sql = @"";
                           for (NSString *keyword in weakSelf->keywordArray)
                           {
                               if ([weakSelf->keywordField.text isEqualToString:weakSelf.keywordString]) sql = [NSString stringWithFormat:@"update %@list set keyword = '%@', type = '0', name = '%@', phone = '%@', sms = '%@', reply = '%@', message = '%@', forward = '%@', number = '%@', sound = '%@' where keyword = '%@'", weakSelf.flag, keyword, weakSelf->nameField.text ?  [weakSelf->nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", weakSelf.phoneAction, weakSelf.messageAction, weakSelf->replySwitch.on == YES ? @"1" : @"0", weakSelf->messageField.text ? [weakSelf->messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", weakSelf.forwardString, weakSelf.numberString, weakSelf->soundSwitch.on == YES ? @"1" : @"0", weakSelf.keywordString];
                               else sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", weakSelf.flag, keyword, weakSelf->nameField.text ?  [weakSelf->nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", weakSelf.phoneAction, weakSelf.messageAction, weakSelf->replySwitch.on == YES ? @"1" : @"0", weakSelf->messageField.text ? [weakSelf->messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", weakSelf.forwardString, weakSelf.numberString, weakSelf->soundSwitch.on == YES ? @"1" : @"0"];
                               
                               int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
                               if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
                           }
                           sqlite3_close(database);
                       }
                       else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
                   });
    
	for (NSString *keyword in keywordArray)
	{
        if ([viewController isKindOfClass:[SNBlacklistViewController class]])
        {
            int index = [((SNBlacklistViewController *)viewController)->keywordArray indexOfObject:self.keywordString];
            if ([keywordField.text isEqualToString:self.keywordString])
            {
                [((SNBlacklistViewController *)viewController)->keywordArray replaceObjectAtIndex:index withObject:keyword];
                [((SNBlacklistViewController *)viewController)->nameArray replaceObjectAtIndex:index withObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
                [((SNBlacklistViewController *)viewController)->replyArray replaceObjectAtIndex:index withObject:replySwitch.on == YES ? @"1" : @"0"];
                [((SNBlacklistViewController *)viewController)->messageArray replaceObjectAtIndex:index withObject:messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
                [((SNBlacklistViewController *)viewController)->forwardArray replaceObjectAtIndex:index withObject:self.forwardString];
                [((SNBlacklistViewController *)viewController)->numberArray replaceObjectAtIndex:index withObject:self.numberString];
                [((SNBlacklistViewController *)viewController)->soundArray replaceObjectAtIndex:index withObject:soundSwitch.on == YES ? @"1" : @"0"];
            }
            else
            {
                [((SNBlacklistViewController *)viewController)->keywordArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->typeArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->nameArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->messageArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->numberArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->smsArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->phoneArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->forwardArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->replyArray removeObjectAtIndex:index];
                [((SNBlacklistViewController *)viewController)->soundArray removeObjectAtIndex:index];
                
                [((SNBlacklistViewController *)viewController)->keywordArray insertObject:keyword atIndex:0];
                [((SNBlacklistViewController *)viewController)->typeArray insertObject:@"0" atIndex:0];
                [((SNBlacklistViewController *)viewController)->nameArray insertObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"" atIndex:0];
                [((SNBlacklistViewController *)viewController)->messageArray insertObject:messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"" atIndex:0];
                [((SNBlacklistViewController *)viewController)->numberArray insertObject:self.numberString atIndex:0];
                [((SNBlacklistViewController *)viewController)->smsArray insertObject:self.messageAction atIndex:0];
                [((SNBlacklistViewController *)viewController)->phoneArray insertObject:self.phoneAction atIndex:0];
                [((SNBlacklistViewController *)viewController)->forwardArray insertObject:self.forwardString atIndex:0];
                [((SNBlacklistViewController *)viewController)->replyArray insertObject:replySwitch.on == YES ? @"1" : @"0" atIndex:0];
                [((SNBlacklistViewController *)viewController)->soundArray insertObject:soundSwitch.on == YES ? @"1" : @"0" atIndex:0];
            }
        }
        else if ([viewController isKindOfClass:[SNWhitelistViewController class]])
        {
            int index = [((SNWhitelistViewController *)viewController)->keywordArray indexOfObject:self.keywordString];
            if ([weakSelf->keywordField.text isEqualToString:weakSelf.keywordString])
            {
                [((SNWhitelistViewController *)viewController)->keywordArray replaceObjectAtIndex:index withObject:keyword];
                [((SNWhitelistViewController *)viewController)->nameArray replaceObjectAtIndex:index withObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
            }
            else
            {
                [((SNWhitelistViewController *)viewController)->keywordArray removeObjectAtIndex:index];
                [((SNWhitelistViewController *)viewController)->typeArray removeObjectAtIndex:index];
                [((SNWhitelistViewController *)viewController)->nameArray removeObjectAtIndex:index];
                
                [((SNWhitelistViewController *)viewController)->keywordArray insertObject:keyword atIndex:0];
                [((SNWhitelistViewController *)viewController)->typeArray insertObject:@"0" atIndex:0];
                [((SNWhitelistViewController *)viewController)->nameArray insertObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"" atIndex:0];
            }
        }
        else if ([viewController isKindOfClass:[SNPrivatelistViewController class]])
        {
            int index = [((SNPrivatelistViewController *)viewController)->keywordArray indexOfObject:self.keywordString];
            if ([weakSelf->keywordField.text isEqualToString:weakSelf.keywordString])
            {
                [((SNPrivatelistViewController *)viewController)->keywordArray replaceObjectAtIndex:index withObject:keyword];
                [((SNPrivatelistViewController *)viewController)->nameArray replaceObjectAtIndex:index withObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
                [((SNPrivatelistViewController *)viewController)->replyArray replaceObjectAtIndex:index withObject:replySwitch.on == YES ? @"1" : @"0"];
                [((SNPrivatelistViewController *)viewController)->messageArray replaceObjectAtIndex:index withObject:messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
                [((SNPrivatelistViewController *)viewController)->forwardArray replaceObjectAtIndex:index withObject:self.forwardString];
                [((SNPrivatelistViewController *)viewController)->numberArray replaceObjectAtIndex:index withObject:self.numberString];
                [((SNPrivatelistViewController *)viewController)->soundArray replaceObjectAtIndex:index withObject:soundSwitch.on == YES ? @"1" : @"0"];
            }
            else
            {
                [((SNPrivatelistViewController *)viewController)->keywordArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->typeArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->nameArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->messageArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->numberArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->smsArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->phoneArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->forwardArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->replyArray removeObjectAtIndex:index];
                [((SNPrivatelistViewController *)viewController)->soundArray removeObjectAtIndex:index];
                
                [((SNPrivatelistViewController *)viewController)->keywordArray insertObject:keyword atIndex:0];
                [((SNPrivatelistViewController *)viewController)->typeArray insertObject:@"0" atIndex:0];
                [((SNPrivatelistViewController *)viewController)->nameArray insertObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"" atIndex:0];
                [((SNPrivatelistViewController *)viewController)->messageArray insertObject:messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"" atIndex:0];
                [((SNPrivatelistViewController *)viewController)->numberArray insertObject:self.numberString atIndex:0];
                [((SNPrivatelistViewController *)viewController)->smsArray insertObject:self.messageAction atIndex:0];
                [((SNPrivatelistViewController *)viewController)->phoneArray insertObject:self.phoneAction atIndex:0];
                [((SNPrivatelistViewController *)viewController)->forwardArray insertObject:self.forwardString atIndex:0];
                [((SNPrivatelistViewController *)viewController)->replyArray insertObject:replySwitch.on == YES ? @"1" : @"0" atIndex:0];
                [((SNPrivatelistViewController *)viewController)->soundArray insertObject:soundSwitch.on == YES ? @"1" : @"0" atIndex:0];
            }
        }
	}
    
    [((UITableViewController *)viewController).tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)dismissKeyboardWithTap:(UITapGestureRecognizer *)tap
{
    [keywordField resignFirstResponder];
    [nameField resignFirstResponder];
    [messageField resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == tapRecognizer && [touch.view isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) return NO;
    return YES;
}
@end