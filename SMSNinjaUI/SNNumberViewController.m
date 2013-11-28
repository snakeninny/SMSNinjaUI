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
#define SETTINGS @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/9E87534C-FD0A-450A-8863-0BAF0D62C9F0/Documents/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/9E87534C-FD0A-450A-8863-0BAF0D62C9F0/Documents/var/mobile/Library/SMSNinja/smsninja.db"
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
	sqlite3 *database;
	for (NSString *keyword in keywordArray)
	{
        int openResult = sqlite3_open([DATABASE UTF8String], &database);
        if (openResult == SQLITE_OK)
		{
            NSString *sql = @"";
            if ([keywordField.text isEqualToString:keywordString]) sql = [NSString stringWithFormat:@"update %@list set keyword = '%@', type = '0', name = '%@', phone = '%@', sms = '%@', reply = '%@', message = '%@', forward = '%@', number = '%@', sound = '%@' where keyword = '%@'", self.flag, keyword, nameField.text ?  [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", self.phoneAction, self.messageAction, replySwitch.on == YES ? @"1" : @"0", messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", self.forwardString, self.numberString, soundSwitch.on == YES ? @"1" : @"0", keywordString];
            else sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", self.flag, keyword, nameField.text ?  [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", self.phoneAction, self.messageAction, replySwitch.on == YES ? @"1" : @"0", messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", self.forwardString, self.numberString, soundSwitch.on == YES ? @"1" : @"0"];
            
            int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
            if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
            sqlite3_close(database);
		}
        else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
        
        if ([viewController isKindOfClass:[SNBlacklistViewController class]])
        {
            [((SNBlacklistViewController *)viewController)->keywordArray replaceObjectAtIndex:[((SNBlacklistViewController *)viewController)->keywordArray indexOfObject:self.keywordString] withObject:keyword];
            [((SNBlacklistViewController *)viewController)->nameArray replaceObjectAtIndex:[((SNBlacklistViewController *)viewController)->nameArray indexOfObject:self.nameString] withObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
            [((SNBlacklistViewController *)viewController)->replyArray replaceObjectAtIndex:[((SNBlacklistViewController *)viewController)->replyArray indexOfObject:self.replyString] withObject:replySwitch.on == YES ? @"1" : @"0"];
            [((SNBlacklistViewController *)viewController)->messageArray replaceObjectAtIndex:[((SNBlacklistViewController *)viewController)->messageArray indexOfObject:self.messageString] withObject:messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
            [((SNBlacklistViewController *)viewController)->forwardArray replaceObjectAtIndex:[((SNBlacklistViewController *)viewController)->forwardArray indexOfObject:self.forwardString] withObject:forwardSwitch.on == YES ? @"1" : @"0"];
            [((SNBlacklistViewController *)viewController)->numberArray replaceObjectAtIndex:[((SNBlacklistViewController *)viewController)->numberArray indexOfObject:self.numberString] withObject:numberField.text ? [numberField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
            [((SNBlacklistViewController *)viewController)->soundArray replaceObjectAtIndex:[((SNBlacklistViewController *)viewController)->soundArray indexOfObject:self.soundString] withObject:soundSwitch.on == YES ? @"1" : @"0"];
        }
        else if ([viewController isKindOfClass:[SNWhitelistViewController class]])
        {
            [((SNWhitelistViewController *)viewController)->keywordArray replaceObjectAtIndex:[((SNWhitelistViewController *)viewController)->keywordArray indexOfObject:self.keywordString] withObject:keyword];
            [((SNWhitelistViewController *)viewController)->nameArray replaceObjectAtIndex:[((SNWhitelistViewController *)viewController)->nameArray indexOfObject:self.nameString] withObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
        }
        else if ([viewController isKindOfClass:[SNPrivatelistViewController class]])
        {
            [((SNPrivatelistViewController *)viewController)->keywordArray replaceObjectAtIndex:[((SNPrivatelistViewController *)viewController)->keywordArray indexOfObject:self.keywordString] withObject:keyword];
            [((SNPrivatelistViewController *)viewController)->nameArray replaceObjectAtIndex:[((SNPrivatelistViewController *)viewController)->nameArray indexOfObject:self.nameString] withObject:nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
            [((SNPrivatelistViewController *)viewController)->replyArray replaceObjectAtIndex:[((SNPrivatelistViewController *)viewController)->replyArray indexOfObject:self.replyString] withObject:replySwitch.on == YES ? @"1" : @"0"];
            [((SNPrivatelistViewController *)viewController)->messageArray replaceObjectAtIndex:[((SNPrivatelistViewController *)viewController)->messageArray indexOfObject:self.messageString] withObject:messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
            [((SNPrivatelistViewController *)viewController)->forwardArray replaceObjectAtIndex:[((SNPrivatelistViewController *)viewController)->forwardArray indexOfObject:self.forwardString] withObject:forwardSwitch.on == YES ? @"1" : @"0"];
            [((SNPrivatelistViewController *)viewController)->numberArray replaceObjectAtIndex:[((SNPrivatelistViewController *)viewController)->numberArray indexOfObject:self.numberString] withObject:numberField.text ? [numberField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @""];
            [((SNPrivatelistViewController *)viewController)->soundArray replaceObjectAtIndex:[((SNPrivatelistViewController *)viewController)->soundArray indexOfObject:self.soundString] withObject:soundSwitch.on == YES ? @"1" : @"0"];
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