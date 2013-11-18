#import <UIKit/UIKit.h>
#import "SMSNinja-private.h"

@interface SNMainViewController : UITableViewController <UITableViewDelegate, UIAlertViewDelegate>
{
	UISwitch *appSwitch;
}
@property (nonatomic, retain) NSNumber *fake;
- (void)saveSettings;
- (void)modifyDatabase;
- (void)gotoSettings;
- (void)gotoReadMe;
- (void)updateDatabase;
@end