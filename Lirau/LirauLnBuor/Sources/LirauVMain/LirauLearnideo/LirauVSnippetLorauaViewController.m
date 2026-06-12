#import "LirauVSnippetLorauaViewController.h"
#import "LirauVSnippetLorauaManager.h"
#import "LirauVSnippetLorauaTopTabsView.h"
#import "LirauVSnippetLorauaCell.h"
#import "LirauStatusIndicatorLorauaVideoStateView.h"
#import "LirauLnBuor-Swift.h"

@interface LirauVSnippetLorauaViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LirauVSnippetLorauaTopTabsView *topTabsView;
@property (nonatomic, strong) LirauStatusIndicatorLorauaVideoStateView *stateView;
@property (nonatomic, strong) NSMutableArray<LirauVSnippetLorauaItem *> *items;
@property (nonatomic, assign) LirauVideoSnippetLorauaCategory category;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL loadingMore;

@end

@implementation LirauVSnippetLorauaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.11 green:0.10 blue:0.18 alpha:1];
    self.items = [NSMutableArray array];
    self.category = LirauVideoSnippetLorauaCategoryHot;
    self.currentPage = 1;
    self.hasMore = NO;
    [self buildDiscoveryFeedLorauaView];
    [self loadFirstVideoSnippetLorauaPage];
}

- (void)buildDiscoveryFeedLorauaView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.collectionView registerClass:LirauVSnippetLorauaCell.class forCellWithReuseIdentifier:[LirauVSnippetLorauaCell videoSnippetLorauaReuseIdentifier]];
    [self.view addSubview:self.collectionView];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = UIColor.whiteColor;
    [refreshControl addTarget:self action:@selector(loadFirstVideoSnippetLorauaPage) forControlEvents:UIControlEventValueChanged];
    self.collectionView.refreshControl = refreshControl;

    self.topTabsView = [[LirauVSnippetLorauaTopTabsView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.topTabsView.videoSnippetLorauaCategoryChangedHandler = ^(LirauVideoSnippetLorauaCategory category) {
        weakSelf.category = category;
        [weakSelf loadFirstVideoSnippetLorauaPage];
    };
    self.topTabsView.videoSnippetLorauaAddHandler = ^{
        NSLog(@"LiraU Video add entry tapped");
        [weakSelf openVideoSnippetLorauaWebPath:[LirauDeepLinkingLorauaRoute videoSnippetLorauaPostVideoPath]];
    };
    [self.view addSubview:self.topTabsView];

    self.stateView = [[LirauStatusIndicatorLorauaVideoStateView alloc] init];
    self.stateView.statusIndicatorLorauaRetryHandler = ^{
        [weakSelf loadFirstVideoSnippetLorauaPage];
    };
    [self.view addSubview:self.stateView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],

        [self.topTabsView.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:15],
        [self.topTabsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.topTabsView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.topTabsView.heightAnchor constraintEqualToConstant:52],

        [self.stateView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.stateView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.stateView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.stateView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor]
    ]];
}

- (void)loadFirstVideoSnippetLorauaPage {
    self.currentPage = 1;
    self.loadingMore = NO;
    if (!self.collectionView.refreshControl.refreshing) {
        [self.stateView showStatusIndicatorLorauaLoading];
    }
    [self loadVideoSnippetLorauaPage:self.currentPage reset:YES];
}

- (void)loadMoreVideoSnippetLorauaIfNeeded {
    if (self.loadingMore || !self.hasMore || self.items.count == 0) {
        return;
    }
    self.loadingMore = YES;
    [self loadVideoSnippetLorauaPage:self.currentPage + 1 reset:NO];
}

- (void)loadVideoSnippetLorauaPage:(NSInteger)page reset:(BOOL)reset {
    __weak typeof(self) weakSelf = self;
    [[LirauVSnippetLorauaManager sharedVideoSnippetLorauaManager] loadVideoSnippetLorauaItemsWithCategory:self.category page:page pageSize:10 completion:^(NSArray<LirauVSnippetLorauaItem *> *items, NSError *error, BOOL hasMore, BOOL usedFallback) {
        [weakSelf.collectionView.refreshControl endRefreshing];
        weakSelf.loadingMore = NO;
        if (reset) {
            [weakSelf.items removeAllObjects];
        }
        if (items.count > 0) {
            [weakSelf.items addObjectsFromArray:items];
        }
        weakSelf.currentPage = page;
        weakSelf.hasMore = hasMore && !usedFallback;
        [weakSelf.collectionView reloadData];

        if (weakSelf.items.count == 0) {
            [weakSelf.stateView showStatusIndicatorLorauaMessage:@"No LiraU videos yet." retryVisible:YES];
        } else {
            [weakSelf.stateView hideStatusIndicatorLorauaState];
            if (usedFallback && error) {
                NSLog(@"LiraU Video fallback shown after request error: %@", error.localizedDescription);
            }
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LirauVSnippetLorauaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LirauVSnippetLorauaCell videoSnippetLorauaReuseIdentifier] forIndexPath:indexPath];
    LirauVSnippetLorauaItem *item = self.items[indexPath.item];
    [cell configureWithNarrativeSharingLorauaItem:item];

    __weak typeof(self) weakSelf = self;
    cell.audienceEngagementLorauaLikeHandler = ^{
        item.likedLocally = !item.likedLocally;
        item.likeCount += item.likedLocally ? 1 : -1;
        NSLog(@"LiraU Video TODO: Like toggled locally for %@", item.dynamicId);
        [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    };
    cell.audienceEngagementLorauaCommentHandler = ^{
        NSLog(@"LiraU Video comment tapped for %@", item.dynamicId);
        [weakSelf openVideoSnippetLorauaWebPath:[LirauDeepLinkingLorauaRoute narrativeSharingLorauaDynamicDetailPathWithDynamicID:item.dynamicId]];
    };
    cell.reportSystemLorauaHandler = ^{
        NSLog(@"LiraU Video report item %@", item.dynamicId);
        [weakSelf openVideoSnippetLorauaWebPath:[LirauDeepLinkingLorauaRoute reportSystemLorauaPathWithDynamicID:item.dynamicId userID:item.userId]];
    };
    cell.languageExchangePartnerLorauaHandler = ^{
        NSLog(@"LiraU Video user tapped %@", item.userId);
        [weakSelf openVideoSnippetLorauaWebPath:[LirauDeepLinkingLorauaRoute languageExchangePartnerLorauaProfilePathWithUserID:item.userId]];
    };
    cell.videoSnippetLorauaHandler = ^{
        NSLog(@"LiraU Video card tapped %@", item.dynamicId);
        [weakSelf openVideoSnippetLorauaWebPath:[LirauDeepLinkingLorauaRoute narrativeSharingLorauaDynamicDetailPathWithDynamicID:item.dynamicId]];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat triggerOffset = scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) * 1.6;
    if (scrollView.contentOffset.y > triggerOffset) {
        [self loadMoreVideoSnippetLorauaIfNeeded];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)openVideoSnippetLorauaWebPath:(NSString *)path {
    if (path.length == 0) {
        return;
    }
    LirauDeepLinkingLorauaPortalViewController *controller = [[LirauDeepLinkingLorauaPortalViewController alloc] initWithDeepLinkingLorauaEntryURLString:path];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
