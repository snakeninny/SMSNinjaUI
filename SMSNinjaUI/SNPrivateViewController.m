#import "SNPrivateViewController.h"
#import "SNPrivateCallHistoryViewController.h"
#import "SNPrivateMessageHistoryViewController.h"
#import "SNTextTableViewCell.h"
#import <sqlite3.h>

#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"

@implementation SNPrivateViewController

- (void)dealloc
{
    [fakePasswordField release];
    fakePasswordField = nil;
    
	[purpleSwitch release];
	purpleSwitch = nil;
    
	[semicolonSwitch release];
	semicolonSwitch = nil;
    
	[super dealloc];
}

- (SNPrivateViewController *)init
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.title = NSLocalizedString(@"Private Zone", @"Private Zone");
        
        fakePasswordField = [[UITextField alloc] initWithFrame:CGRectZero];
        purpleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        semicolonSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 1)
		return 1;
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SNTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) cell = [[[SNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];
    
    NSDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
    
    switch (indexPath.section)
    {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Private Info", @"Private Info");
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Privatelist", @"Privatelist");
                break;
        }
            
            break;
        case 1:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"FakePW", @"FakePW");
            fakePasswordField.delegate = self;
            fakePasswordField.secureTextEntry = YES;
            fakePasswordField.placeholder = NSLocalizedString(@"Input fake password", @"Input fake password");
            fakePasswordField.text = [dictionary objectForKey:@"fakePassword"];
            fakePasswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:fakePasswordField];
            
            break;
        case 2:
            switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Purple Square", @"Purple Square");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = purpleSwitch;
                purpleSwitch.on = [[dictionary objectForKey:@"shouldShowPurpleSquare"] boolValue];
                [purpleSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];
                
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Show semicolon", @"Show semicolon");
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = semicolonSwitch;
                semicolonSwitch.on = [[dictionary objectForKey:@"shouldShowSemicolon"] boolValue];
                [semicolonSwitch addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];
                
                break;
        }
            break;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		switch (indexPath.row)
		{
			case 0:
            {
                SNPrivateMessageHistoryViewController *privateMessageHistoryViewController = [[SNPrivateMessageHistoryViewController alloc] init];
                [self.navigationController pushViewController:privateMessageHistoryViewController animated:YES];
                [privateMessageHistoryViewController release];
                
                break;
            }
			case 1:
            {
                SNPrivateCallHistoryViewController *privateCallHistoryViewController = [[SNPrivateCallHistoryViewController alloc] init];
                [self.navigationController pushViewController:privateCallHistoryViewController animated:YES];
                [privateCallHistoryViewController release];
                
                break;
            }
		}
	}
}

- (void)saveSettings
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
	[dictionary setObject:[NSNumber numberWithBool:purpleSwitch.on] forKey:@"shouldShowPurpleSquare"];
	[dictionary setObject:[NSNumber numberWithBool:semicolonSwitch.on] forKey:@"shouldShowSemicolon"];
	[dictionary writeToFile:SETTINGS atomically:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
	[dictionary setObject:textField.text ? textField.text : @"" forKey:@"fakePassword"];
	[dictionary writeToFile:SETTINGS atomically:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}
@end