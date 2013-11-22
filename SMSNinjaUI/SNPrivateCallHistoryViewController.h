#import <UIKit/UIKit.h>

@interface SNPrivateCallHistoryViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
	NSMutableArray *idArray;
	NSMutableArray *nameArray;
	NSMutableArray *numberArray;
	NSMutableArray *contentArray;
	NSMutableArray *timeArray;
	NSMutableSet *bulkSet;
	int chosenRow;
}
- (void)loadDatabaseSegment;
- (void)selectAll:(UIBarButtonItem *)buttonItem;
- (void)bulkDelete;
- (void)gotoPrivateView;
- (void)segmentAction:(id)sender;
@end
