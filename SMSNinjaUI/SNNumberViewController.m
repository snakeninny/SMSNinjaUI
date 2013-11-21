#import "SNNumberViewController.h"
#import "SNCallActionViewController.h"
#import "SNMessageActionViewController.h"
#import "SNTextTableViewCell.h"
#import <sqlite3.h>

#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"

@implementation SNNumberViewController

@synthesize nameField;
@synthesize nameString;
@synthesize keywordField;
@synthesize keywordString;
@synthesize phoneAction;
@synthesize messageAction;
@synthesize replySwitch;
@synthesize replyString;
@synthesize messageField;
@synthesize messageString;
@synthesize soundSwitch;
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
    
	[super dealloc];
}

- (SNNumberViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = NSLocalizedString(@"Details", @"Details");
        
        UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101];
        [backButton addTarget:self action:@selector(gotoList) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:NSLocalizedString(@"List", @"List") forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
        
        nameField = [[UITextField alloc] initWithFrame:CGRectZero];
        keywordField = [[UITextField alloc] initWithFrame:CGRectZero];
        replySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        messageField = [[UITextField alloc] initWithFrame:CGRectZero];
        soundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        
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
	SNTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"any-cell"] autorelease];
    
    switch (indexPath.section)
    {
        case 0:
        {
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
        }
        case 1:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Call", @"Call");
                if ([self.phoneAction isEqualToString:@"1"]) cell.detailTextLabel.text = NSLocalizedString(@"Disconnect", @"Disconnect");
                else if ([self.phoneAction isEqualToString:@"2"]) cell.detailTextLabel.text = NSLocalizedString(@"Ignore", @"Ignore");
                else if ([self.phoneAction isEqualToString:@"3"]) cell.detailTextLabel.text = NSLocalizedString(@"Let go", @"Let go");
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
        }
        case 2:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Auto reply", @"Auto reply");
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
        }
        case 3:
        {
            cell.textLabel.text = NSLocalizedString(@"Beep", @"Beep");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.accessoryView = soundSwitch;
            soundSwitch.on = [self.soundString isEqualToString:@"0"] ? NO : YES;
            [cell.contentView addSubview:soundSwitch];
            
            break;
        }
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
}

- (void)gotoList
{
	NSString *tempString = keywordField.text ? keywordField.text : @"";
	NSRange range = [tempString rangeOfString:@" "];
    [keywordArray removeAllObjects];
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
        int openResult = sqlite3_open([DATABASE UTF8String], &database);
        if (openResult == SQLITE_OK)
		{
			NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '0', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", self.flag, keyword, nameField.text ?  [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", self.phoneAction, self.messageAction, replySwitch.on == YES ? @"1" : @"0", messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", self.forwardString, self.numberString, soundSwitch.on == YES ? @"1" : @"0"];
            
            int execResult = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
            if (execResult != SQLITE_OK) NSLog(@"SMSNinja: Failed to exec %@, error %d", sql, execResult);
            sqlite3_close(database);
		}
	}
    
    id viewController = [self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] - 2)];
    if ([viewController respondsToSelector:@selector(loadDatabaseSegment)]) [viewController loadDatabaseSegment];
    [((UITableViewController *)viewController).tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}
@end
