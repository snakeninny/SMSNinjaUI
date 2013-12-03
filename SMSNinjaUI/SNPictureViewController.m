#import "SNPictureViewController.h"

@implementation SNPictureViewController

@synthesize idString;
@synthesize flag;

- (void)dealloc
{
    [idString release];
    idString = nil;
    
    [flag release];
    flag = nil;
    
    [pictureScrollView release];
    pictureScrollView = nil;
    
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        pictureScrollView = [[UIScrollView alloc] init];
        pictureScrollView.delegate = self;
        pictureScrollView.frame = CGRectMake([UIScreen mainScreen].applicationFrame.origin.x, [UIScreen mainScreen].applicationFrame.origin.y, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height);
        pictureScrollView.contentSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width * picturesCount, pictureScrollView.bounds.size.height);
        pictureScrollView.showsVerticalScrollIndicator = NO;
        pictureScrollView.showsHorizontalScrollIndicator = NO;
        pictureScrollView.pagingEnabled = YES;
        pictureScrollView.userInteractionEnabled = YES;
        pictureScrollView.backgroundColor = [UIColor whiteColor];
        self.wantsFullScreenLayout = YES;
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
            self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 7)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [pictureScrollView addGestureRecognizer:tapGesture];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture release];
    
    for (int i = 0; i < 2; i++)
    {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Users/snakeninny/Desktop/iOS7-Wallpaper-Pack/%d.png", i + 1]];
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width * i, 0.0f, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView.tag = i + 1;
        [pictureScrollView addSubview:imageView];
        [image release];
        [imageView release];
    }
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Picture %d/picturesCount", @"Picture %d/picturesCount"), 1];
    [self.view addSubview:pictureScrollView];
}

- (void)restoreTitle:(NSString *)title
{
    if ([self.title isEqualToString:NSLocalizedString(@"Done saving", @"Done saving")]) self.title = title;
}

- (void)saveToAlbum
{
    int currentViewIndex = ceil(pictureScrollView.contentOffset.x / [UIScreen mainScreen].applicationFrame.size.width);
    int currentViewTag = currentViewIndex + 1;
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Users/snakeninny/Desktop/iOS7-Wallpaper-Pack/%d.png", currentViewTag]];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [image release];
    NSString *originalTitle = self.title;
    self.title = NSLocalizedString(@"Done saving", @"Done saving");
    [self performSelector:@selector(restoreTitle:) withObject:originalTitle afterDelay:2.0f];
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    BOOL shouldHide = !self.navigationController.navigationBarHidden;
    
    if (!shouldHide)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:shouldHide withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:shouldHide animated:NO];
    }
    
    [UIView transitionWithView:self.navigationController.view
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [[UIApplication sharedApplication] setStatusBarHidden:shouldHide withAnimation:UIStatusBarAnimationFade];
                        [self.navigationController setNavigationBarHidden:shouldHide animated:NO];
                    }
                    completion:nil];
}

- (void)pictureScrollViewDidEndDecelerating:(UIScrollView *)view
{
    int currentViewIndex = ceil(view.contentOffset.x / [UIScreen mainScreen].applicationFrame.size.width);
    int currentViewTag = currentViewIndex + 1;
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Picture %d/picturesCount", @"Picture %d/picturesCount"), currentViewTag];
}

- (void)pictureScrollViewDidScroll:(UIScrollView *)view
{
    int currentViewIndex = ceil(view.contentOffset.x / [UIScreen mainScreen].applicationFrame.size.width);
    int currentViewTag = currentViewIndex + 1;
    
    if ([view viewWithTag:currentViewTag + 1] == nil && currentViewTag != picturesCount) // next
    {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Users/snakeninny/Desktop/iOS7-Wallpaper-Pack/%d.png", currentViewTag + 1]];
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width * (currentViewIndex + 1), 0.0f, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView.tag = currentViewTag + 1;
        [pictureScrollView addSubview:imageView];
        [image release];
        [imageView release];
    }
    if ([view viewWithTag:currentViewTag - 1] == nil && currentViewTag != 0) // previous
    {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Users/snakeninny/Desktop/iOS7-Wallpaper-Pack/%d.png", currentViewTag - 1]];
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width * (currentViewIndex - 1), 0.0f, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView.tag = currentViewTag - 1;
        [pictureScrollView addSubview:imageView];
        [image release];
        [imageView release];
    }
    
    for (UIView *subview in [view subviews])
        if (subview.tag != currentViewTag && subview.tag != currentViewTag - 1 && subview.tag != currentViewTag + 1)
            [subview removeFromSuperview];
}
@end