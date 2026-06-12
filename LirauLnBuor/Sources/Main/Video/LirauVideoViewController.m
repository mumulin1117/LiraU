#import "LirauVideoViewController.h"
#import "LirauVideoManager.h"
#import "LirauVideoTopTabsView.h"
#import "LirauVideoCell.h"
#import "LirauVideoStateView.h"
#import "LirauLnBuor-Swift.h"

@interface LirauVideoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LirauVideoTopTabsView *topTabsView;
@property (nonatomic, strong) LirauVideoStateView *stateView;
@property (nonatomic, strong) NSMutableArray<LirauVideoItem *> *items;
@property (nonatomic, assign) LirauVideoCategory category;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL loadingMore;

@end

@implementation LirauVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.11 green:0.10 blue:0.18 alpha:1];
    self.items = [NSMutableArray array];
    self.category = LirauVideoCategoryHot;
    self.currentPage = 1;
    self.hasMore = NO;
    [self buildView];
    [self loadFirstPage];
}

- (void)buildView {
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
    [self.collectionView registerClass:LirauVideoCell.class forCellWithReuseIdentifier:[LirauVideoCell reuseIdentifier]];
    [self.view addSubview:self.collectionView];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = UIColor.whiteColor;
    [refreshControl addTarget:self action:@selector(loadFirstPage) forControlEvents:UIControlEventValueChanged];
    self.collectionView.refreshControl = refreshControl;

    self.topTabsView = [[LirauVideoTopTabsView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.topTabsView.categoryChangedHandler = ^(LirauVideoCategory category) {
        weakSelf.category = category;
        [weakSelf loadFirstPage];
    };
    self.topTabsView.addHandler = ^{
        NSLog(@"LiraU Video add entry tapped");
        [weakSelf openLirauWebPath:[LirauWebRoute postVideoPath]];
    };
    [self.view addSubview:self.topTabsView];

    self.stateView = [[LirauVideoStateView alloc] init];
    self.stateView.retryHandler = ^{
        [weakSelf loadFirstPage];
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

- (void)loadFirstPage {
    self.currentPage = 1;
    self.loadingMore = NO;
    if (!self.collectionView.refreshControl.refreshing) {
        [self.stateView showLoading];
    }
    [self loadPage:self.currentPage reset:YES];
}

- (void)loadMoreIfNeeded {
    if (self.loadingMore || !self.hasMore || self.items.count == 0) {
        return;
    }
    self.loadingMore = YES;
    [self loadPage:self.currentPage + 1 reset:NO];
}

- (void)loadPage:(NSInteger)page reset:(BOOL)reset {
    __weak typeof(self) weakSelf = self;
    [[LirauVideoManager sharedManager] loadVideosWithCategory:self.category page:page pageSize:10 completion:^(NSArray<LirauVideoItem *> *items, NSError *error, BOOL hasMore, BOOL usedFallback) {
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
            [weakSelf.stateView showMessage:@"No LiraU videos yet." retryVisible:YES];
        } else {
            [weakSelf.stateView hideState];
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
    LirauVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LirauVideoCell reuseIdentifier] forIndexPath:indexPath];
    LirauVideoItem *item = self.items[indexPath.item];
    [cell configureWithItem:item];

    __weak typeof(self) weakSelf = self;
    cell.likeHandler = ^{
        item.likedLocally = !item.likedLocally;
        item.likeCount += item.likedLocally ? 1 : -1;
        NSLog(@"LiraU Video TODO: Like toggled locally for %@", item.dynamicId);
        [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    };
    cell.commentHandler = ^{
        NSLog(@"LiraU Video comment tapped for %@", item.dynamicId);
        [weakSelf openLirauWebPath:[LirauWebRoute dynamicDetailPathWithDynamicID:item.dynamicId]];
    };
    cell.reportHandler = ^{
        NSLog(@"LiraU Video report item %@", item.dynamicId);
        [weakSelf openLirauWebPath:[LirauWebRoute reportPathWithDynamicID:item.dynamicId userID:item.userId]];
    };
    cell.userHandler = ^{
        NSLog(@"LiraU Video user tapped %@", item.userId);
        [weakSelf openLirauWebPath:[LirauWebRoute learnerProfilePathWithUserID:item.userId]];
    };
    cell.videoHandler = ^{
        NSLog(@"LiraU Video card tapped %@", item.dynamicId);
        [weakSelf openLirauWebPath:[LirauWebRoute dynamicDetailPathWithDynamicID:item.dynamicId]];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat triggerOffset = scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) * 1.6;
    if (scrollView.contentOffset.y > triggerOffset) {
        [self loadMoreIfNeeded];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)openLirauWebPath:(NSString *)path {
    if (path.length == 0) {
        return;
    }
    LirauWebPortalViewController *controller = [[LirauWebPortalViewController alloc] initWithEntryURLString:path];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
