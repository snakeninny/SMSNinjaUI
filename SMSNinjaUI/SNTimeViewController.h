#import <UIKit/UIKit.h>

@interface SNTimeViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
	UITableView *settingsTableView;
    UIPickerView *timePickerView;
}
@property (nonatomic, retain) NSString *keywordString;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic, retain) NSString *phoneAction;
@property (nonatomic, retain) NSString *messageAction;
@property (nonatomic, retain) NSString *replyString;
@property (nonatomic, retain) UISwitch *replySwitch;
@property (nonatomic, retain) UITextField *messageField;
@property (nonatomic, retain) NSString *messageString;
@property (nonatomic, retain) NSString *soundString;
@property (nonatomic, retain) UISwitch *soundSwitch;
@property (nonatomic, retain) NSString *forwardString; // in another view
@property (nonatomic, retain) NSString *numberString; // in another view
- (void)gotoList;
- (void)saveControlStates;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
@end
