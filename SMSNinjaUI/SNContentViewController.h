#import <UIKit/UIKit.h>

@interface SNContentViewController : UITableViewController <UITextFieldDelegate>
{
	NSMutableArray *keywordArray;
}
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) UITextField *keywordField;
@property (nonatomic, retain) NSString *keywordString;
@property (nonatomic, retain) UISwitch *forwardSwitch;
@property (nonatomic, retain) NSString *forwardString;
@property (nonatomic, retain) UITextField *numberField;
@property (nonatomic, retain) NSString *numberString;
@property (nonatomic, retain) UISwitch *replySwitch;
@property (nonatomic, retain) NSString *replyString;
@property (nonatomic, retain) UITextField *messageField;
@property (nonatomic, retain) NSString *messageString;
@property (nonatomic, retain) UISwitch *soundSwitch;
@property (nonatomic, retain) NSString *soundString;
@property (nonatomic, retain) NSString *flag;
@end
