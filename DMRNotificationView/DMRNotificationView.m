//
//  DMRNotificationView.m
//  notificationview
//
//  Created by Damir Tursunovic on 1/23/13.
//  Copyright (c) 2013 Damir Tursunovic (damir.me). All rights reserved.
//

#import "DMRNotificationView.h"

// Change these values to match your needs...
static CGFloat kNotificationViewTintColorTransparency = 0.80;           // Default tint color transparency
static NSTimeInterval kNotificationViewDefaultHideTimeInterval = 4.5;   // Number of seconds until auto dismiss
static CGFloat kNotificationViewVerticalInset = 10.0;                   // Top and bottom inset
static CGFloat kNotificationViewLabelVerticalPadding = 5.0;             // Distance between title and subtitle
static CGFloat kNotificationViewShadowOffset = 5.0;                     // Shadow offset

@implementation DMRNotificationView

-(void)dealloc
{
    [self setDidTapHandler:nil];
}




#pragma mark -
#pragma mark Default Initializer

-(id)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle targetView:(UIView *)view image:(UIImage *)image
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setContentMode:UIViewContentModeRedraw];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        self.transparency = kNotificationViewTintColorTransparency;
        [self setTitle:title];
        [self setSubTitle:subTitle];
        [self setTargetView:view];
        [self setIsTransparent:YES];
        [self setTintColor:[UIColor colorWithRed:0.133 green:0.267 blue:0.533 alpha:1.000]];
        [self setHideTimeInterval:kNotificationViewDefaultHideTimeInterval];
        self.image = image;
    }
    return self;
}



#pragma mark -
#pragma mark Convenience Initializers

+(void)showInView:(UIView *)view title:(NSString *)title subTitle:(NSString *)subTitle
{
    [self showInView:view title:title subTitle:subTitle tintColor:nil image:nil];
}

+(void)showInView:(UIView *)view
            title:(NSString *)title
         subTitle:(NSString *)subTitle
        tintColor:(UIColor *)tintColor
            image:(UIImage *)image
{
    DMRNotificationView *notificationView = [[self alloc] initWithTitle:title
                                                               subTitle:subTitle
                                                             targetView:view
                                                                  image:image];
    
    if (tintColor)
        [notificationView setTintColor:tintColor];
    
    [notificationView showAnimated:YES];
}

+(void)showWarningInView:(UIView *)view title:(NSString *)title subTitle:(NSString *)subTitle image:(UIImage *)image
{
    [self showInView:view
               title:title
            subTitle:subTitle
           tintColor:[self tintColorForType:DMRNotificationViewTypeWarning]
               image:image];
}

+(void)showSuccessInView:(UIView *)view title:(NSString *)title subTitle:(NSString *)subTitle image:(UIImage *)image
{
    [self showInView:view
               title:title
            subTitle:subTitle
           tintColor:[self tintColorForType:DMRNotificationViewTypeSuccess]
               image:image];
}




#pragma mark -
#pragma mark Drawing

-(void)drawRect:(CGRect)rect
{
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ref);
 
    // Tint color
    CGContextSetFillColorWithColor(ref, _tintColor.CGColor);
    CGContextSetShadowWithColor(ref, CGSizeMake(0.0, 1.0),
                                kNotificationViewShadowOffset,
                                [UIColor colorWithWhite:0.0 alpha:1.0].CGColor);
    CGContextFillRect(ref, CGRectMake(rect.origin.x,
                                      rect.origin.y,
                                      rect.size.width,
                                      rect.size.height-kNotificationViewShadowOffset));
    CGContextRestoreGState(ref);

    UIColor *textColor = [self textColor];                  // Depends on fillColor
    BOOL textIncludesShadow = [self textIncludesShadow];    // Depends on fillColor
    CGFloat labelVerticalPosition = kNotificationViewVerticalInset;    
    
    // Title
    if (_title.length > 0)
    {
        CGSize titleSize = [self expectedTitleSize];
        CGRect rect = CGRectMake(10.0,
                                 labelVerticalPosition,
                                 _targetView.bounds.size.width-20.0,
                                 titleSize.height);
        if (self.attributedTitle) {
            [self.attributedTitle drawInRect:rect];
        } else {
            [textColor set];

            if (textIncludesShadow)
                CGContextSetShadowWithColor(ref,
                                            CGSizeMake(0.0, -1.0),
                                            0.f,
                                            [UIColor colorWithWhite:0.0 alpha:0.3].CGColor);

            NSMutableParagraphStyle *textMutableStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            textMutableStyle.lineBreakMode = NSLineBreakByWordWrapping;
            textMutableStyle.alignment     = NSTextAlignmentCenter;
            NSMutableParagraphStyle *textStyle = [textMutableStyle copy];
            
            [self.title drawInRect:rect
                    withAttributes:@{NSFontAttributeName            : [self titleFont],
                                     NSForegroundColorAttributeName : [self textColor],
                                     NSParagraphStyleAttributeName  : textStyle}];

            labelVerticalPosition += titleSize.height+kNotificationViewLabelVerticalPadding;
        }
    }
    
    // Image
    if (self.image)
    {
        CGFloat x = (self.targetView.bounds.size.width - 20.f
                     - [self.title sizeWithAttributes:
                        @{NSFontAttributeName : self.titleFont}].width) / 2.f
        - self.image.size.width - 10.f;
        CGFloat y = kNotificationViewVerticalInset;
        [self.image drawAtPoint:CGPointMake(x, y)];
    }
    
    // Subtitle
    if (_subTitle.length > 0)
    {
        CGSize subTitleSize = [self expectedSubTitleSize];
        CGRect rect = CGRectMake((_targetView.bounds.size.width-subTitleSize.width)/2,
                                 labelVerticalPosition,
                                 _targetView.bounds.size.width - 20.f,
                                 subTitleSize.height);
        if (self.attributedSubtitle) {
            [self.attributedSubtitle drawInRect:rect];
        } else {
            [textColor set];

            if (textIncludesShadow) {
                CGContextSetShadowWithColor(ref,
                                            CGSizeMake(0.0, -1.0),
                                            0.0,
                                            [UIColor colorWithWhite:0.0 alpha:0.3].CGColor);
            }
            NSMutableParagraphStyle *textMutableStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            textMutableStyle.lineBreakMode = NSLineBreakByWordWrapping;
            textMutableStyle.alignment     = NSTextAlignmentLeft;
            NSMutableParagraphStyle *textStyle = [textMutableStyle copy];
            
            [self.subTitle drawInRect:rect
                       withAttributes:@{NSFontAttributeName            : [self subTitleFont],
                                        NSForegroundColorAttributeName : [self textColor],
                                        NSParagraphStyleAttributeName  : textStyle}];
        }
    }
    
    // Lines
    CGContextSetAllowsAntialiasing(ref, false);
    CGContextSetLineWidth(ref, 1.0);
}




#pragma mark -
#pragma mark Public

-(void)showInView:(UIView *)view
{
    [self setTargetView:view];
    [self showAnimated:YES];
}


-(void)showAnimated:(BOOL)animated
{
    CGSize expectedSize = [self expectedSize];
    [self setFrame:CGRectMake(0.0, 0.0, expectedSize.width, expectedSize.height)];
    
    CGPoint animateToCenter = self.center;
    [self setCenter:CGPointMake(self.center.x, self.center.y-self.bounds.size.height)];
    [_targetView addSubview:self];
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self setCenter:animateToCenter];
        } completion:nil];
    }
    else
    {
        [self setCenter:animateToCenter];
    }
    
    if (_hideTimeInterval > 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _hideTimeInterval* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissAnimated:YES];
        });
    }
}

-(void)dismissAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self setCenter:CGPointMake(self.center.x, -self.bounds.size.height)];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    else
    {
        [self removeFromSuperview];
    }
}





#pragma mark -
#pragma mark Setters

-(void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    if (self.attributedTitle == attributedTitle) {
        return;
    }
    self->_attributedTitle = attributedTitle;
    self.title = self.attributedTitle.string;
}

-(void)setAttributedSubtitle:(NSAttributedString *)attributedSubtitle
{
    if (self.attributedSubtitle == attributedSubtitle) {
        return;
    }
    self->_attributedSubtitle = attributedSubtitle;
    self.subTitle = self.attributedSubtitle.string;
}

-(void)setTintColor:(UIColor *)tintColor
{
    if (tintColor == _tintColor)
        return;
    
    if ([tintColor isEqual:[UIColor clearColor]] || !tintColor)
        [NSException raise:NSInvalidArgumentException format:@"Tint color cannot be [UIColor clearColor] or nil"];

    _tintColor = [self transparentTintColorFromColor:tintColor];
}

-(void)setTargetView:(UIView *)targetView
{
    if (_targetView == targetView)
        return;
    
    if (!targetView)
        [NSException raise:NSInvalidArgumentException format:@"DMRNotificationView must have a targetView"];
    
    _targetView = targetView;
}

-(void)setTitle:(NSString *)title
{
    if (_title == title)
        return;
    
    if (title.length == 0)
        [NSException raise:NSInvalidArgumentException format:@"DMRNotificationView cannot have an empty title"];
    
    _title = title;
}

-(void)setType:(DMRNotificationViewType)type
{
    if (_type == type)
        return;
    
    _type = type;
    
    [self setTintColor:[DMRNotificationView tintColorForType:type]];
}

-(void)setIsTransparent:(BOOL)transparent
{
    _transparent = transparent;
    
    UIColor *tintColor = _tintColor;
    _tintColor = nil;
    [self setTintColor:tintColor];
}



#pragma mark -
#pragma mark Getters

-(UIColor *)transparentTintColorFromColor:(UIColor *)color
{
    CGFloat opacity = (_transparent) ? self.transparency : 1.0;
    CGColorRef transparentColor = CGColorCreateCopyWithAlpha(color.CGColor, opacity);
    
    UIColor *newColor = [UIColor colorWithCGColor:transparentColor];
    CGColorRelease(transparentColor);
    
    return newColor;
}

-(UIColor *)textColor
{   
    CGFloat white = 0;
    [_tintColor getWhite:&white alpha:nil];
    return (white < 0.65) ? [UIColor whiteColor] : [UIColor colorWithRed:0.187 green:0.187 blue:0.187 alpha:1.000];
}

-(BOOL)textIncludesShadow
{
    CGFloat white = 0;
    [_tintColor getWhite:&white alpha:nil];
    return (white < 0.65);
}

-(CGSize)expectedSize
{
    CGFloat height = kNotificationViewVerticalInset;
    
    height += [self expectedTitleSize].height;
    
    if (_subTitle.length > 0)
        height += [self expectedSubTitleSize].height+(kNotificationViewLabelVerticalPadding*2);
    
    height += kNotificationViewVerticalInset+kNotificationViewShadowOffset;
    
    return CGSizeMake(_targetView.bounds.size.width, height);
}

-(CGSize)expectedSubTitleSize
{
    if (_subTitle.length == 0) {
        return CGSizeZero;
    }
    NSMutableParagraphStyle *textMutableStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textMutableStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textMutableStyle.alignment     = NSTextAlignmentLeft;
    NSMutableParagraphStyle *textStyle = [textMutableStyle copy];
    
    CGSize size =
    [self.subTitle boundingRectWithSize:CGSizeMake(_targetView.bounds.size.width - 20.f, 999.f)
                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                             attributes:@{NSFontAttributeName            : [self subTitleFont],
                                          NSForegroundColorAttributeName : [self textColor],
                                          NSParagraphStyleAttributeName  : textStyle}
                                context:nil].size;

    //iPhone5s iOS7 fix
    size.height += 2;
    return size;
}

-(CGSize)expectedTitleSize
{
    if (_title.length == 0) {
        return CGSizeZero;
    }
    NSMutableParagraphStyle *textMutableStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textMutableStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textMutableStyle.alignment     = NSTextAlignmentCenter;
    NSMutableParagraphStyle *textStyle = [textMutableStyle copy];

    return
    [self.title boundingRectWithSize:CGSizeMake(_targetView.bounds.size.width - 20.f, 999.f)
                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                          attributes:@{NSFontAttributeName            : [self titleFont],
                                       NSForegroundColorAttributeName : [self textColor],
                                       NSParagraphStyleAttributeName  : textStyle}
                             context:nil].size;
}

-(UIFont *)titleFont
{
    if (_titleFont)
        return _titleFont;
    
    return [UIFont boldSystemFontOfSize:18.0];
}

-(UIFont *)subTitleFont
{
    if (_subTitleFont)
        return _subTitleFont;
    
    return [UIFont systemFontOfSize:15.0];
}

+(UIColor *)tintColorForType:(DMRNotificationViewType)type
{
    if (type == DMRNotificationViewTypeWarning)
        return [UIColor colorWithRed:0.725 green:0.000 blue:0.068 alpha:1.000];
    
    if (type == DMRNotificationViewTypeSuccess)
        return [UIColor greenColor];
    
    return [UIColor colorWithRed:0.133 green:0.267 blue:0.533 alpha:1.000];
}




#pragma mark -
#pragma mark UIView

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.frame, touchLocation))
    {
        if (_didTapHandler)
        {
            _didTapHandler();
            [self setDidTapHandler:nil];
        }
        
        [self dismissAnimated:YES];
    }
}

@end
