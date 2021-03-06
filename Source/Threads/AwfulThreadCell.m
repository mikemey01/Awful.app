//  AwfulThreadCell.m
//
//  Copyright 2013 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

#import "AwfulThreadCell.h"

@interface AwfulThreadCell ()

@property (strong, nonatomic) UIImageView *pagesIconImageView;

@property (strong, nonatomic) id longPressTarget;
@property (assign, nonatomic) SEL longPressAction;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

@end

@implementation AwfulThreadCell

@synthesize fontName = _fontName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
        _stickyImageView = [UIImageView new];
        _stickyImageView.contentMode = UIViewContentModeTopRight;
        [self.contentView addSubview:_stickyImageView];
        
        _tagAndRatingView = [AwfulThreadTagAndRatingView new];
        [self.contentView addSubview:_tagAndRatingView];
        
        self.textLabel.numberOfLines = 2;
        
        _numberOfPagesLabel = [UILabel new];
        [self.contentView addSubview:_numberOfPagesLabel];
        
        UIImage *pageTemplateImage = [[UIImage imageNamed:@"pages"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _pagesIconImageView = [[UIImageView alloc] initWithImage:pageTemplateImage];
        [self.contentView addSubview:_pagesIconImageView];
        
        [self setFontName:nil];
        
        _badgeLabel = [UILabel new];
        _badgeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.textLabel.font.pointSize];
        _badgeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_badgeLabel];
    }
    return self;
}

- (void)setThreadTagHidden:(BOOL)threadTagHidden
{
    if (_threadTagHidden == threadTagHidden) return;
    _threadTagHidden = threadTagHidden;
    self.tagAndRatingView.hidden = threadTagHidden;
    [self setNeedsLayout];
}

- (BOOL)pageIconHidden
{
    return self.pagesIconImageView.hidden;
}

- (void)setPageIconHidden:(BOOL)pageIconHidden
{
    if (self.pageIconHidden == pageIconHidden) return;
    self.pagesIconImageView.hidden = pageIconHidden;
    [self setNeedsLayout];
}

- (void)setLightenBadgeLabel:(BOOL)lightenBadgeLabel
{
    if (_lightenBadgeLabel == lightenBadgeLabel) return;
    _lightenBadgeLabel = lightenBadgeLabel;
    NSString *fontName = lightenBadgeLabel ? @"HelveticaNeue-Light" : @"HelveticaNeue-Medium";
    self.badgeLabel.font = [UIFont fontWithName:fontName size:self.textLabel.font.pointSize];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    _pagesIconImageView.tintColor = self.tintColor;
}

- (NSString *)fontName
{
    return _fontName ?: self.textLabel.font.fontName;
}

- (void)setFontName:(NSString *)fontName
{
    if ([_fontName isEqualToString:fontName]) return;
    _fontName = [fontName copy];
    
    UIFontDescriptor *textLabelDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    self.textLabel.font = [UIFont fontWithName:(fontName ?: [textLabelDescriptor objectForKey:UIFontDescriptorNameAttribute])
                                          size:textLabelDescriptor.pointSize];
    
    UIFontDescriptor *numberOfPagesDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
    _numberOfPagesLabel.font = [UIFont fontWithName:(fontName ?: [numberOfPagesDescriptor objectForKey:UIFontDescriptorNameAttribute])
                                               size:numberOfPagesDescriptor.pointSize];
    
    UIFontDescriptor *detailTextLabelDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption2];
    self.detailTextLabel.font = [UIFont fontWithName:(fontName ?: [detailTextLabelDescriptor objectForKey:UIFontDescriptorNameAttribute])
                                                size:detailTextLabelDescriptor.pointSize];
}

- (void)setLongPressTarget:(id)target action:(SEL)action
{
    if (action) {
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
        [self addGestureRecognizer:self.longPressRecognizer];
    } else {
        [self.longPressRecognizer.view removeGestureRecognizer:self.longPressRecognizer];
        self.longPressRecognizer = nil;
    }
    self.longPressTarget = target;
    self.longPressAction = action;
}

- (void)didLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [[UIApplication sharedApplication] sendAction:self.longPressAction to:self.longPressTarget from:self forEvent:nil];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect remainder = UIEdgeInsetsInsetRect(self.contentView.bounds, Padding);
    
    if (self.threadTagHidden) {
        remainder = UIEdgeInsetsInsetRect(remainder, AdditionalPaddingHidingTag);
    } else {
        CGRect tagAndRatingFrame;
        CGRectDivide(remainder, &tagAndRatingFrame, &remainder, TagWidth, CGRectMinXEdge);
        self.tagAndRatingView.frame = tagAndRatingFrame;
        remainder = UIEdgeInsetsInsetRect(remainder, AdditionalTagPadding);
    }
    
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(remainder), 0, 0);
    
    self.badgeLabel.frame = CGRectMake(0, 0, CGRectGetWidth(remainder), 0);
    [self.badgeLabel sizeToFit];
    CGRect badgeFrame;
    CGRectDivide(remainder, &badgeFrame, &remainder, CGRectGetWidth(self.badgeLabel.bounds), CGRectMaxXEdge);
    self.badgeLabel.frame = badgeFrame;
    
    remainder.size.width -= 6;
    self.textLabel.frame = CGRectMake(0, 0, CGRectGetWidth(remainder), 0);
    [self.textLabel sizeToFit];
    self.numberOfPagesLabel.frame = CGRectMake(0, 0, CGRectGetWidth(remainder), 0);
    [self.numberOfPagesLabel sizeToFit];
    self.detailTextLabel.frame = CGRectMake(0, 0, CGRectGetWidth(remainder), 0);
    [self.detailTextLabel sizeToFit];
    CGFloat totalHeight = CGRectGetHeight(self.textLabel.bounds) + TextDetailTextSeparatorHeight + CGRectGetHeight(self.detailTextLabel.bounds);
    CGRect textRect = CGRectInset(remainder, 0, (CGRectGetHeight(remainder) - totalHeight) / 2);
    
    CGRect titleFrame = textRect;
    titleFrame.size.height = CGRectGetHeight(self.textLabel.bounds);
    self.textLabel.frame = titleFrame;
    
    CGRect pagesFrame = self.numberOfPagesLabel.bounds;
    pagesFrame.origin.x = CGRectGetMinX(textRect);
    pagesFrame.origin.y = CGRectGetMaxY(textRect) - CGRectGetHeight(pagesFrame);
    self.numberOfPagesLabel.frame = pagesFrame;
    
    CGRect iconFrame = self.pagesIconImageView.bounds;
    if (self.pageIconHidden) {
        iconFrame.origin.x = CGRectGetMaxX(pagesFrame);
    } else {
        iconFrame.origin.x = CGRectGetMaxX(pagesFrame) + 2;
    }
    iconFrame.origin.y = CGRectGetMaxY(pagesFrame) + self.numberOfPagesLabel.font.descender - CGRectGetHeight(iconFrame);
    self.pagesIconImageView.frame = iconFrame;
    
    CGRect byFrame = self.detailTextLabel.bounds;
    if (self.pageIconHidden) {
        byFrame.origin.x = CGRectGetMinX(iconFrame);
    } else {
        byFrame.origin.x = CGRectGetMaxX(iconFrame) + 5;
    }
    byFrame.origin.y = CGRectGetMaxY(pagesFrame) + self.numberOfPagesLabel.font.descender - CGRectGetHeight(byFrame) - self.detailTextLabel.font.descender;
    self.detailTextLabel.frame = byFrame;
    
    [self.stickyImageView sizeToFit];
    CGRect stickyFrame = self.stickyImageView.bounds;
    stickyFrame.origin.x = CGRectGetMaxX(self.contentView.bounds) - CGRectGetWidth(stickyFrame);
    stickyFrame.origin.y = CGRectGetMinY(self.contentView.bounds);
    self.stickyImageView.frame = stickyFrame;
}

static const UIEdgeInsets Padding = { .left = 4, .right = 8 };
static const UIEdgeInsets AdditionalPaddingHidingTag = { .left = 11 };
static const CGFloat TagWidth = 45;
static const UIEdgeInsets AdditionalTagPadding = { .left = 9 };
static const CGFloat TextDetailTextSeparatorHeight = 2;

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat initialWidth = size.width;
    size.width -= Padding.left + Padding.right;
    if (self.threadTagHidden) {
        size.width -= AdditionalPaddingHidingTag.left + AdditionalPaddingHidingTag.right;
    } else {
        size.width -= TagWidth + AdditionalTagPadding.left + AdditionalTagPadding.right;
    }
    size.width -= [self.badgeLabel sizeThatFits:size].width;
    CGFloat textHeight = [self.textLabel sizeThatFits:size].height + [self.detailTextLabel sizeThatFits:size].height;
    return CGSizeMake(initialWidth, textHeight + TextDetailTextSeparatorHeight);
}

@end
