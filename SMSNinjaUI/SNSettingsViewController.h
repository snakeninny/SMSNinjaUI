#import <UIKit/UIKit.h>

@interface SNSettingsViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, retain) NSNumber *fake;
@property (nonatomic, retain) UISwitch *iconBadgeSwitch;
@property (nonatomic, retain) UISwitch *statusBarBadgeSwitch;
@property (nonatomic, retain) UISwitch *hideIconSwitch;
@property (nonatomic, retain) UISwitch *clearSwitch;
@property (nonatomic, retain) UISwitch *addressbookSwitch;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UITextField *launchCodeField;
- (void)resetSettings;
- (void)saveSettings;
@end
