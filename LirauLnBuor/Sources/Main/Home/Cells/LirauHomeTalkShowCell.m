#import "LirauHomeTalkShowCell.h"

@interface LirauHomeTalkShowCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CAGradientLayer *placeholderLayer;
@property (nonatomic, strong) CAGradientLayer *shadeLayer;
@property (nonatomic, copy) NSString *currentImageURLString;

@end

@implementation LirauHomeTalkShowCell

+ (NSString *)reuseIdentifier {
    return @"LirauHomeTalkShowCell";
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
    self.imageView.image = nil;
    self.currentImageURLString = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderLayer.frame = self.contentView.bounds;
    self.shadeLayer.frame = self.contentView.bounds;
}

- (void)buildView {
    self.contentView.layer.cornerRadius = 24;
    self.contentView.clipsToBounds = YES;

    _placeholderLayer = [CAGradientLayer layer];
    _placeholderLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:0.28 green:0.19 blue:0.42 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.08 green:0.07 blue:0.12 alpha:1].CGColor
    ];
    _placeholderLayer.startPoint = CGPointMake(0, 0);
    _placeholderLayer.endPoint = CGPointMake(1, 1);
    [self.contentView.layer addSublayer:_placeholderLayer];

    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];

    _shadeLayer = [CAGradientLayer layer];
    _shadeLayer.colors = @[
        (__bridge id)[UIColor clearColor].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.72].CGColor
    ];
    _shadeLayer.startPoint = CGPointMake(0.5, 0.4);
    _shadeLayer.endPoint = CGPointMake(0.5, 1);
    [self.contentView.layer addSublayer:_shadeLayer];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.30];
    _titleLabel.layer.cornerRadius = 13;
    _titleLabel.clipsToBounds = YES;
    [self.contentView addSubview:_titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [_imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [_imageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [_imageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [_imageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [_titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor constant:18],
        [_titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-18],
        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [_titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16],
        [_titleLabel.heightAnchor constraintGreaterThanOrEqualToConstant:28]
    ]];
}

- (void)configureWithItem:(LirauHomeDynamicItem *)item highlightedCard:(BOOL)highlightedCard {
    self.titleLabel.text = item.title;
    self.contentView.alpha = highlightedCard ? 1.0 : 0.70;
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
                weakSelf.imageView.image = image;
            }
        });
    }] resume];
}

@end
