#import "SNContentViewController.h"
#import "SNTextTableViewCell.h"
#import <sqlite3.h>

#ifndef SMSNinjaDebug
#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"
#else
#define SETTINGS @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/9E87534C-FD0A-450A-8863-0BAF0D62C9F0/Documents/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/9E87534C-FD0A-450A-8863-0BAF0D62C9F0/Documents/var/mobile/Library/SMSNinja/smsninja.db"
#endif

@implementation SNContentViewController

@synthesize nameString;
@synthesize keywordString;
@synthesize forwardString;
@synthesize numberString;
@synthesize replyString;
@synthesize messageString;
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
    
    [tapRecognizer release];
    tapRecognizer = nil;
    
	[super dealloc];
}

- (SNContentViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = NSLocalizedString(@"Details", @"Details");
        
        nameField = [[UITextField alloc] initWithFrame:CGRectZero];
        keywordField = [[UITextField alloc] initWithFrame:CGRectZero];
        forwardSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        numberField = [[UITextField alloc] initWithFrame:CGRectZero];
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
	if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView *subview in [cell.contentView subviews])
        [subview removeFromSuperview];
    
    switch (indexPath.section)
    {
        case 0:
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
                keywordField.delegate = self;
                keywordField.placeholder = NSLocalizedString(@"Input here", @"Input here");
                keywordField.text = self.keywordString;
                keywordField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [cell.contentView addSubview:keywordField];
            }
            
            break;
        case 1:
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
        case 2:
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
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Beep", @"Beep");
            cell.accessoryView = soundSwitch;
            soundSwitch.on = [self.soundString isEqualToString:@"0"] ? NO : YES;
            
            break;
    }
    
	return cell;
}

- (void)viewWillDisappear:(BOOL)animated
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
        else NSLog(@"SMSNinja: Failed to open %@, error %d", DATABASE, openResult);
	}
    
    id viewController = [self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] - 2)];
    SEL selector = NSSelectorFromString(@"loadDatabaseSegment");
    if ([viewController respondsToSelector:selector]) [viewController performSelector:selector];
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
    [numberField resignFirstResponder];
    [messageField resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == tapRecognizer && [touch.view isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) return NO;
    return YES;
}
@end