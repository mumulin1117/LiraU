#import "LirauProfilePostCell.h"

@interface LirauProfilePostCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIView *authorChipView;
@property (nonatomic, strong) UIImageView *authorAvatarView;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIImageView *moreImageView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UIView *captionOverlayView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) NSURLSessionDataTask *coverTask;
@property (nonatomic, strong) NSURLSessionDataTask *avatarTask;

@end

@implementation LirauProfilePostCell

+ (NSString *)reuseIdentifier {
    return @"LirauProfilePostCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.coverTask cancel];
    [self.avatarTask cancel];
    self.coverTask = nil;
    self.avatarTask = nil;
    self.coverImageView.image = [UIImage imageNamed:@"lira_profile_post_placeholder"];
    self.authorAvatarView.image = [UIImage imageNamed:@"lira_profile_post_author_avatar"];
}

- (void)setupViews {
    self.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    self.contentView.layer.cornerRadius = 28;
    self.contentView.clipsToBounds = YES;

    self.coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_post_placeholder"]];
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.coverImageView];

    self.authorChipView = [[UIView alloc] init];
    self.authorChipView.translatesAutoresizingMaskIntoConstraints = NO;
    self.authorChipView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.34];
    self.authorChipView.layer.cornerRadius = 20;
    self.authorChipView.clipsToBounds = YES;
    [self.contentView addSubview:self.authorChipView];

    self.authorAvatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_post_author_avatar"]];
    self.authorAvatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.authorAvatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.authorAvatarView.layer.cornerRadius = 20;
    self.authorAvatarView.clipsToBounds = YES;
    [self.authorChipView addSubview:self.authorAvatarView];

    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.authorLabel.textColor = UIColor.whiteColor;
    self.authorLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.authorLabel.adjustsFontSizeToFitWidth = YES;
    self.authorLabel.minimumScaleFactor = 0.75;
    [self.authorChipView addSubview:self.authorLabel];

    self.moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_post_more_button"]];
    self.moreImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.moreImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.moreImageView];

    self.playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_post_play"]];
    self.playImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.playImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.playImageView];

    self.captionOverlayView = [[UIView alloc] init];
    self.captionOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    self.captionOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    [self.contentView addSubview:self.captionOverlayView];

    self.captionLabel = [[UILabel alloc] init];
    self.captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.captionLabel.textColor = UIColor.whiteColor;
    self.captionLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.captionLabel.numberOfLines = 1;
    [self.captionOverlayView addSubview:self.captionLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.coverImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.coverImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.coverImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.coverImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],

        [self.authorChipView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [self.authorChipView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.authorChipView.widthAnchor constraintGreaterThanOrEqualToConstant:92],
        [self.authorChipView.widthAnchor constraintLessThanOrEqualToConstant:154],
        [self.authorChipView.heightAnchor constraintEqualToConstant:40],

        [self.authorAvatarView.leadingAnchor constraintEqualToAnchor:self.authorChipView.leadingAnchor],
        [self.authorAvatarView.topAnchor constraintEqualToAnchor:self.authorChipView.topAnchor],
        [self.authorAvatarView.widthAnchor constraintEqualToConstant:40],
        [self.authorAvatarView.heightAnchor constraintEqualToConstant:40],

        [self.authorLabel.leadingAnchor constraintEqualToAnchor:self.authorAvatarView.trailingAnchor constant:12],
        [self.authorLabel.trailingAnchor constraintEqualToAnchor:self.authorChipView.trailingAnchor constant:-14],
        [self.authorLabel.centerYAnchor constraintEqualToAnchor:self.authorChipView.centerYAnchor],

        [self.moreImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [self.moreImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.moreImageView.widthAnchor constraintEqualToConstant:40],
        [self.moreImageView.heightAnchor constraintEqualToConstant:40],

        [self.playImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.playImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:10],
        [self.playImageView.widthAnchor constraintEqualToConstant:48],
        [self.playImageView.heightAnchor constraintEqualToConstant:48],

        [self.captionOverlayView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.captionOverlayView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.captionOverlayView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [self.captionOverlayView.heightAnchor constraintEqualToConstant:60],

        [self.captionLabel.leadingAnchor constraintEqualToAnchor:self.captionOverlayView.leadingAnchor constant:26],
        [self.captionLabel.trailingAnchor constraintEqualToAnchor:self.captionOverlayView.trailingAnchor constant:-20],
        [self.captionLabel.centerYAnchor constraintEqualToAnchor:self.captionOverlayView.centerYAnchor]
    ]];
}

- (void)configureWithPost:(LirauProfilePost *)post {
    self.authorLabel.text = post.authorName.length > 0 ? post.authorName : @"LiraU";
    self.captionLabel.text = post.title.length > 0 ? post.title : post.content;
    self.playImageView.hidden = !post.hasVideo;
    [self loadImageURLString:post.coverURLString intoImageView:self.coverImageView fallbackName:@"lira_profile_post_placeholder" taskSetter:^(NSURLSessionDataTask *task) {
        self.coverTask = task;
    }];
    [self loadImageURLString:post.authorAvatarURLString intoImageView:self.authorAvatarView fallbackName:@"lira_profile_post_author_avatar" taskSetter:^(NSURLSessionDataTask *task) {
        self.avatarTask = task;
    }];
}

- (void)loadImageURLString:(NSString *)urlString
             intoImageView:(UIImageView *)imageView
              fallbackName:(NSString *)fallbackName
                taskSetter:(void (^)(NSURLSessionDataTask *task))taskSetter {
    imageView.image = [UIImage imageNamed:fallbackName];
    NSURL *url = [NSURL URLWithString:urlString ?: @""];
    if (!url) {
        return;
    }

    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = data.length > 0 ? [UIImage imageWithData:data] : nil;
        if (!image) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    }];
    taskSetter(task);
    [task resume];
}

@end
