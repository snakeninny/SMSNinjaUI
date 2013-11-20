#import "SNTimeViewController.h"
#import "SNCallActionViewController.h"
#import "SNMessageActionViewController.h"
#import "SNTextTableViewCell.h"
#import <sqlite3.h>

#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"

@implementation SNTimeViewController

@synthesize keywordString;
@synthesize nameField;
@synthesize nameString;
@synthesize phoneAction;
@synthesize messageAction;
@synthesize replyString;
@synthesize replySwitch;
@synthesize messageField;
@synthesize messageString;
@synthesize soundString;
@synthesize soundSwitch;
@synthesize forwardString;
@synthesize numberString;

- (SNTimeViewController *)init
{
	if ((self = [super init]))
	{
		self.title= NSLocalizedString(@"Time", @"Time");
        
        UIButton* backButton = [UIButton buttonWithType:(UIButtonType)101];
        [backButton addTarget:self action:@selector(gotoList) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitle:NSLocalizedString(@"List", @"List") forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
        
        nameField = [[UITextField alloc] initWithFrame:CGRectZero];
        replySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        messageField = [[UITextField alloc] initWithFrame:CGRectZero];
        soundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	}
	return self;
}

- (void)viewDidLoad
{
    timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height / 2.0f)];
	timePickerView.delegate = self;
	timePickerView.showsSelectionIndicator = YES;
	[self.view addSubview:timePickerView];
    
	NSString *duration = self.keywordString;
	NSString *one = [duration substringToIndex:[duration rangeOfString:@":"].location];
	duration = [duration substringFromIndex:[duration rangeOfString:@":"].location + 1];
	NSString *two = [duration substringToIndex:[duration rangeOfString:@"~"].location];
	duration = [duration substringFromIndex:[duration rangeOfString:@"~"].location + 1];
	NSString *three = [duration substringToIndex:[duration rangeOfString:@":"].location];
	duration = [duration substringFromIndex:[duration rangeOfString:@":"].location + 1];
	NSString *four = duration;
    
	[timePickerView selectRow:(4800 + [one intValue]) inComponent:0 animated:YES];
	[timePickerView selectRow:(4800 + [two intValue]) inComponent:1 animated:YES];
	[timePickerView selectRow:0 inComponent:2 animated:YES];
	[timePickerView selectRow:(4800 + [three intValue]) inComponent:3 animated:YES];
	[timePickerView selectRow:(4800 + [four intValue]) inComponent:4 animated:YES];
    
	settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, timePickerView.bounds.size.height, timePickerView.bounds.size.width, self.view.bounds.size.height - timePickerView.bounds.size.height) style:UITableViewStyleGrouped];
	settingsTableView.dataSource = self;
	settingsTableView.delegate = self;
	[self.view addSubview:settingsTableView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 5;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 2)
		return 1;
    
	return 10000;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 50.0f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (component == 0 || component == 3)
		return [NSString stringWithFormat:(row % 24 < 10 ? @"0%d" : @"%d"), row % 24];
	else if (component == 1 || component == 4)
		return [NSString stringWithFormat:(row % 60 < 10 ? @"0%d" : @"%d"), row % 60];
	return @"~";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0 || section == 3)
		return 1;
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SNTextTableViewCell *cell = [settingsTableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"any-cell"] autorelease];
    
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            nameField.placeholder = NSLocalizedString(@"Input here", @"Input here");
            nameField.text = self.nameString;
            nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
            nameField.delegate = self;
            [cell.contentView addSubview:nameField];
            
            break;
        case 1:
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Call", @"Call");
                cell.detailTextLabel.text = NSLocalizedString(@"Ignore", @"Ignore");
                if ([self.phoneAction isEqualToString:@"1"]) cell.detailTextLabel.text = NSLocalizedString(@"Disconnect", @"Disconnect");
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
        case 2: // 到此
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Auto reply", @"Auto reply");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [replySwitch release];
                replySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                cell.accessoryView = replySwitch;
                replySwitch.on = [self.replyString isEqualToString:@"0"] ? NO : YES;
                [replySwitch addTarget:self action:@selector(stayUnchanged) forControlEvents:UIControlEventValueChanged];
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
                [replyField addTarget:self action:@selector(stayUnchanged) forControlEvents:UIControlEventEditingDidEnd];
                replyField.clearButtonMode = UITextFieldViewModeWhileEditing;
                replyField.placeholder = NSLocalizedString(@"Message here", @"Message here");
                [cell.contentView addSubview:replyField];
            }
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Beep", @"Beep");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [soundSwitch release];
            soundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = soundSwitch;
            soundSwitch.on = [self.soundString isEqualToString:@"0"] ? NO : YES;
            [soundSwitch addTarget:self action:@selector(stayUnchanged) forControlEvents:UIControlEventValueChanged];
            break;
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
                callDetailSettingsViewController.flag = @"black";
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
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)saveControlStates
{
	self.nameString = nil;
	self.replyString = nil;
	self.messageString = nil;
	self.soundString = nil;
    
	self.nameString = nameField.text;
	self.replyString = replySwitch.on ? @"1" : @"0";
	self.messageString = replyField.text;
	self.soundString = soundSwitch.on ? @"1" : @"0";
}

- (void)saveSettings
{
	NSString *one = [NSString stringWithFormat:([timePickerView selectedRowInComponent:0] % 24 < 10 ? @"0%d" : @"%d"), [timePickerView selectedRowInComponent:0] % 24];
	NSString *two = [NSString stringWithFormat:([timePickerView selectedRowInComponent:1] % 60 < 10 ? @"0%d" : @"%d"), [timePickerView selectedRowInComponent:1] % 60];
	NSString *three = [NSString stringWithFormat:([timePickerView selectedRowInComponent:3] % 24 < 10 ? @"0%d" : @"%d"), [timePickerView selectedRowInComponent:3] % 24];
	NSString *four = [NSString stringWithFormat:([timePickerView selectedRowInComponent:4] % 60 < 10 ? @"0%d" : @"%d"), [timePickerView selectedRowInComponent:4] % 60];
	NSString *keyword = [[[[[[one stringByAppendingString:@":"] stringByAppendingString:two] stringByAppendingString:@"~"] stringByAppendingString:three] stringByAppendingString:@":"] stringByAppendingString:four];
    
	sqlite3 *database;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"insert or replace into blacklist (keyword, type, name, phone, sms, reply, message, forward, number, sound) values ('%@', '2', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", keyword, [nameField.text length] == 0 ? @"" : [nameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"], self.phoneString, self.smsString, replySwitch ? (replySwitch.on == YES ? @"1" : @"0") : self.replyString, replyField ? ([replyField.text length] == 0 ? @"" : [replyField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"]) : self.messageString, self.forwardString, self.numberString, soundSwitch ? (soundSwitch.on == YES ? @"1" : @"0") : self.soundString];
        
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK)
			NSLog(@"SNERROR: %s", [sql UTF8String]);
		sqlite3_close(database);
	}
    
	for (UIViewController *viewController in self.navigationController.viewControllers)
	{
		if ([viewController isKindOfClass:[BlacklistViewController class]])
		{
			BlacklistViewController *blacklistViewControllerClass = (BlacklistViewController *)viewController;
			[blacklistViewControllerClass initDB];
			[blacklistViewControllerClass.tableView reloadData];
			[self.navigationController popToViewController:blacklistViewControllerClass animated:YES];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self saveControlStates];
	[self animateTextField:textField up:NO];
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)up
{
	const int movementDistance = 200;
	const float movementDuration = 0.3f;
	int movement = up ? -movementDistance : movementDistance;
	[UIView beginAnimations:@"animation" context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration: movementDuration];
	self.view.frame = CGRectOffset(self.view.frame, 0, movement);
	[UIView commitAnimations];
}

- (void)dealloc
{
	[timePickerView release];
	timePickerView = nil;
    
	[settingsTableView release];
	settingsTableView = nil;
    
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
    
	[soundString release];
	soundString = nil;
    
	[nameField release];
	nameField = nil;
    
	[replySwitch release];
	replySwitch = nil;
    
	[replyField release];
	replyField = nil;
    
	[soundSwitch release];
	soundSwitch = nil;
    
	[super dealloc];
}
@end
