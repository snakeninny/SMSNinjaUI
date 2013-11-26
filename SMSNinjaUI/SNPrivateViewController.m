#import "SNPrivateViewController.h"
#import "SNPrivatelistViewController.h"
#import "SNPrivateMessageHistoryViewController.h"
#import "SNTextTableViewCell.h"
#import <sqlite3.h>

#ifndef SMSNinjaDebug
#define SETTINGS @"/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/var/mobile/Library/SMSNinja/smsninja.db"
#else
#define SETTINGS @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/0C9D35FB-B626-42B7-AAE9-45F6F537890B/Documents/var/mobile/Library/SMSNinja/smsninja.plist"
#define DATABASE @"/Users/snakeninny/Library/Application Support/iPhone Simulator/7.0.3/Applications/0C9D35FB-B626-42B7-AAE9-45F6F537890B/Documents/var/mobile/Library/SMSNinja/smsninja.db"
#endif

@implementation SNPrivateViewController

- (void)dealloc
{
    [fakePasswordField release];
    fakePasswordField = nil;
    
	[purpleSwitch release];
	purpleSwitch = nil;
    
	[semicolonSwitch release];
	semicolonSwitch = nil;
    
    [tapRecognizer release];
    tapRecognizer = nil;
    
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
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardWithTap:)];
        tapRecognizer.delegate = self;
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
                cell.textLabel.text = NSLocalizedString(@"Show Semicolon", @"Show Semicolon");
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
                SNPrivatelistViewController *privatelistViewController = [[SNPrivatelistViewController alloc] init];
                [self.navigationController pushViewController:privatelistViewController animated:YES];
                [privatelistViewController release];
                
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)dismissKeyboardWithTap:(UITapGestureRecognizer *)tap
{
    [fakePasswordField resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == tapRecognizer && [touch.view isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) return NO;
    return YES;
}
@end