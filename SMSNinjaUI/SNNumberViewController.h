#import <UIKit/UIKit.h>
// 到此
@interface SNNumberViewController : UITableViewController <UITextFieldDelegate>
{
	NSString *nameString;
	NSString *keywordString;
	NSString *phoneString;
	NSString *smsString;
	NSString *replyString;
	NSString *messageString;
	NSString *forwardString;
	NSString *numberString;
	NSString *soundString;
	NSString *flag;

	NSMutableArray *keywordArray;

	UITextField *nameField;
	UITextField *numberField;
	UISwitch *replySwitch;
	UITextField *replyField;
	UISwitch *soundSwitch;
}
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) NSString *keywordString;
@property (nonatomic, retain) NSString *phoneString;
@property (nonatomic, retain) NSString *smsString;
@property (nonatomic, retain) NSString *replyString;
@property (nonatomic, retain) NSString *messageString;
@property (nonatomic, retain) NSString *forwardString;
@property (nonatomic, retain) NSString *numberString;
@property (nonatomic, retain) NSString *soundString;
@property (nonatomic, retain) NSString *flag;

- (void)saveConfig;
@end
