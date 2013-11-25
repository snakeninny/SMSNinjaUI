#import <UIKit/UIKit.h>

@interface SNNumberViewController : UITableViewController <UITextFieldDelegate>
{
	NSMutableArray *keywordArray;
}
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) UITextField *keywordField;
@property (nonatomic, retain) NSString *keywordString;
@property (nonatomic, retain) NSString *phoneAction;
@property (nonatomic, retain) NSString *messageAction;
@property (nonatomic, retain) UISwitch *replySwitch;
@property (nonatomic, retain) NSString *replyString;
@property (nonatomic, retain) UITextField *messageField;
@property (nonatomic, retain) NSString *messageString;
@property (nonatomic, retain) UISwitch *soundSwitch;
@property (nonatomic, retain) NSString *soundString;
@property (nonatomic, retain) NSString *flag;
@property (nonatomic, retain) NSString *forwardString; // in another view
@property (nonatomic, retain) NSString *numberString; // in another view
@end
