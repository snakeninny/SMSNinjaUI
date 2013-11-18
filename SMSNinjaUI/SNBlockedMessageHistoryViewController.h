#import <UIKit/UIKit.h>
#import "SNBlockedCallHistoryViewController.h"

@interface SNBlockedMessageHistoryViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
	NSMutableArray *idArray;
	NSMutableArray *nameArray;
	NSMutableArray *numberArray;
	NSMutableArray *contentArray;
	NSMutableArray *timeArray;
	NSMutableArray *readArray;
	NSMutableArray *picturesArray;
	NSMutableSet *bulkSet;
	int chosenRow;
}

- (void)loadDatabaseSegment;
- (void)selectAll;
- (void)bulkDelete;
- (void)bulkUnread;
- (void)bulkRead;
- (void)gotoMainViewController;
- (void)segmentAction:(id)sender;
@end
