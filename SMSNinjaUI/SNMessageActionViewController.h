#import <UIKit/UIKit.h>

@interface SNMessageActionViewController : UITableViewController <UITextFieldDelegate>
{
	UISwitch *forwardSwitch;
	UITextField *numberField;
}
@property (nonatomic, retain) NSString *messageAction;
@property (nonatomic, retain) NSString *forwardString;
@property (nonatomic, retain) NSString *numberString;
@end
