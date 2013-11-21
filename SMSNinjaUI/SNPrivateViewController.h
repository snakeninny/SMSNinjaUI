#import <UIKit/UIKit.h>

@interface SNPrivateViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    UITextField *fakePasswordField;
	UISwitch *purpleSwitch;
	UISwitch *semicolonSwitch;
}
- (void)saveSettings;
@end
