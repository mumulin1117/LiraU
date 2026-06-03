#import "LirauHomeWordBitsCell.h"

@interface LirauHomeWordBitsCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UILabel *storeLabel;
@property (nonatomic, copy) NSString *currentImageURLString;

@end

@implementation LirauHomeWordBitsCell

+ (NSString *)reuseIdentifier {
    return @"LirauHomeWordBitsCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverImageView.image = nil;
    self.currentImageURLString = @"";
}

- (void)buildView {
    self.contentView.backgroundColor = [UIColor colorWithRed:0.18 green:0.16 blue:0.28 alpha:1];
    self.contentView.layer.cornerRadius = 18;
    self.contentView.clipsToBounds = YES;

    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _coverImageView.backgroundColor = [UIColor colorWithRed:0.34 green:0.24 blue:0.46 alpha:1];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    _coverImageView.layer.cornerRadius = 14;
    [self.contentView addSubview:_coverImageView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];

    _contentLabel = [[UILabel alloc] init];
    _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _contentLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    _contentLabel.textColor = [UIColor colorWithWhite:1 alpha:0.56];
    _contentLabel.numberOfLines = 2;
    [self.contentView addSubview:_contentLabel];

    UIImageView *praiseIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_home_metric_fire"]];
    praiseIcon.translatesAutoresizingMaskIntoConstraints = NO;
    praiseIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:praiseIcon];

    _praiseLabel = [[UILabel alloc] init];
    _praiseLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _praiseLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    _praiseLabel.textColor = [UIColor colorWithWhite:1 alpha:0.72];
    [self.contentView addSubview:_praiseLabel];

    UIImageView *storeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_home_metric_star"]];
    storeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    storeIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:storeIcon];

    _storeLabel = [[UILabel alloc] init];
    _storeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _storeLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    _storeLabel.textColor = [UIColor colorWithWhite:1 alpha:0.72];
    [self.contentView addSubview:_storeLabel];

    [NSLayoutConstraint activateConstraints:@[
        [_coverImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
        [_coverImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [_coverImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        [_coverImageView.widthAnchor constraintEqualToConstant:84],

        [_titleLabel.leadingAnchor constraintEqualToAnchor:_coverImageView.trailingAnchor constant:12],
        [_titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:15],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],

        [_contentLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
        [_contentLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:5],
        [_contentLabel.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor],

        [praiseIcon.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
        [praiseIcon.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-13],
        [praiseIcon.widthAnchor constraintEqualToConstant:16],
        [praiseIcon.heightAnchor constraintEqualToConstant:16],
        [_praiseLabel.leadingAnchor constraintEqualToAnchor:praiseIcon.trailingAnchor constant:4],
        [_praiseLabel.centerYAnchor constraintEqualToAnchor:praiseIcon.centerYAnchor],

        [storeIcon.leadingAnchor constraintEqualToAnchor:_praiseLabel.trailingAnchor constant:14],
        [storeIcon.centerYAnchor constraintEqualToAnchor:praiseIcon.centerYAnchor],
        [storeIcon.widthAnchor constraintEqualToConstant:16],
        [storeIcon.heightAnchor constraintEqualToConstant:16],
        [_storeLabel.leadingAnchor constraintEqualToAnchor:storeIcon.trailingAnchor constant:4],
        [_storeLabel.centerYAnchor constraintEqualToAnchor:storeIcon.centerYAnchor],
        [_storeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-12]
    ]];
}

- (void)configureWithItem:(LirauHomeDynamicItem *)item {
    self.titleLabel.text = item.title;
    self.contentLabel.text = item.content;
    self.praiseLabel.text = [NSString stringWithFormat:@"%ld", (long)item.praiseCount];
    self.storeLabel.text = [NSString stringWithFormat:@"%ld", (long)item.storeCount];
    self.currentImageURLString = item.imageURLString ?: @"";
    [self loadImageFromURLString:self.currentImageURLString];
}

- (void)loadImageFromURLString:(NSString *)urlString {
    if (urlString.length == 0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || data.length == 0) {
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.currentImageURLString isEqualToString:urlString]) {
                weakSelf.coverImageView.image = image;
            }
        });
    }] resume];
}

@end
