@interface UISwitch (private)
- (void)setAlternateColors:(BOOL)colors;
@end

@interface UITextView (private)
- (void)setContentToHTMLString:(id)htmlstring;
@end

@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)named;
- (id)sendMessageAndReceiveReplyName:(id)name userInfo:(id)info;
- (BOOL)sendMessageName:(id)name userInfo:(id)info;
- (void)runServerOnCurrentThread;
- (void)registerForMessageName:(id)messageName target:(id)target selector:(SEL)selector;
@end