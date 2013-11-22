#import "SNContentViewController.h"
#import "SNTextTableViewCell.h"
#import <sqlite3.h>

#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"

@implementation SNContentViewController

@synthesize nameField;
@synthesize nameString;
@synthesize keywordField;
@synthesize keywordString;
@synthesize forwardSwitch;
@synthesize forwardString;
@synthesize numberField;
@synthesize numberString;
@synthesize replySwitch;
@synthesize replyString;
@synthesize messageField;
@synthesize messageString;
@synthesize soundSwitch;
@synthesize soundString;
@synthesize flag;

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
    
	[forwardSwitch release];
	forwardSwitch = nil;
    
	[forwardString release];
	forwardString = nil;
    
	[replyString release];
	replyString = nil;
    
	[messageString release];
	messageString = nil;
    
	[numberField release];
	numberField = nil;
    
	[numberString release];
	numberString = nil;
    
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
    
	[flag release];
	flag = nil;
    
	[keywordArray release];
	keywordArray = nil;
    
	[super dealloc];
}

- (SNContentViewController *)init
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
        forwardSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        numberField = [[UITextField alloc] initWithFrame:CGRectZero];
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
	if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
                nameField.delegate = self;
                nameField.placeholder = NSLocalizedString(@"Input here", @"Input here");
                nameField.text = self.nameString;
                nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [cell.contentView addSubview:nameField];
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Keyword", @"Keyword");
                numberField.delegate = self;
                numberField.placeholder = NSLocalizedString(@"Input here", @"Input here");
                numberField.text = self.keywordString;
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
                cell.accessoryView = forwardSwitch;
                forwardSwitch.on = [self.forwardString isEqualToString:@"0"] ? NO : YES;
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"To", @"To");
                numberField.delegate = self;
                numberField.text = self.numberString;
                numberField.clearButtonMode = UITextFieldViewModeWhileEditing;
                numberField.placeholder = NSLocalizedString(@"Number here", @"Number here");
                [cell.contentView addSubview:numberField];
            }
            
            break;
        }
        case 2:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Reply", @"Reply");
                cell.accessoryView = replySwitch;
                replySwitch.on = [self.replyString isEqualToString:@"0"] ? NO : YES;
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"With", @"With");
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
            cell.accessoryView = soundSwitch;
            soundSwitch.on = [self.soundString isEqualToString:@"0"] ? NO : YES;
            
            break;
        }
    }
    
	return cell;
}

- (void)gotoList
{
	NSString *tempString = numberField.text ? numberField.text : @"";
	NSRange range = [tempString rangeOfString:@" "];
	while (range.location != NSNotFound)
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
			NSString *sql = [NSString stringWithFormat:@"insert or replace into %@list (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '1', '%@', '0', '1', '%@', '%@', '%@', '%@', '%@')", self.flag, keyword, nameField.text ? [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", replySwitch.on == YES ? @"1" : @"0", messageField.text ? [messageField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", forwardSwitch.on == YES ? @"1" : @"0", numberField.text ? [numberField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"] : @"", soundSwitch.on == YES ? @"1" : @"0"];
            
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