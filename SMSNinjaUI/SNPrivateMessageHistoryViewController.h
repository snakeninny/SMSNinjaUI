#import <UIKit/UIKit.h>

@interface SNPrivateMessageHistoryViewController : UITableViewController <UIAlertViewDelegate>
{
	NSMutableArray *idArray;
	NSMutableArray *nameArray;
	NSMutableArray *numberArray;
	NSMutableArray *contentArray;
	NSMutableArray *timeArray;
	NSMutableArray *picturesArray;

	int chosenRow;
}
- (void)initDB;
- (void)deleteAll;
- (void)gotoPrivateViewController;
- (void)segmentAction:(id)sender;
@end
