//
//  MBCircularProgressBarLayer.m
//  MBCircularProgressBar
//
//  Created by Mati Bot on 7/9/15.
//  Copyright (c) 2015 Mati Bot All rights reserved.
//

@import UIKit;
@import CoreGraphics;

#import "MBCircularProgressBarLayer.h"

@implementation MBCircularProgressBarLayer
@dynamic value;
@dynamic maxValue;
@dynamic borderPadding;
@dynamic valueFontSize;
@dynamic unitString;
@dynamic unitFontSize;
@dynamic progressLineWidth;
@dynamic progressColor;
@dynamic progressStrokeColor;
@dynamic emptyLineWidth;
@dynamic progressAngle;
@dynamic emptyLineColor;
@dynamic emptyLineStrokeColor;
@dynamic emptyCapType;
@dynamic progressCapType;
@dynamic fontColor;
@dynamic progressRotationAngle;
@dynamic progressAppearanceType;
@dynamic decimalPlaces;
@dynamic valueDecimalFontSize;
@dynamic unitFontName;
@dynamic valueFontName;
@dynamic showUnitString;
@dynamic showValueString;
@dynamic textOffset;
@dynamic countdown;
@dynamic isLine;
@dynamic isVertical;
@dynamic anotationLeft;
@dynamic anotationTitle;

static CGFloat _margin = 10;
static CGFloat _anotationOffset = 30;

#pragma mark - Drawing

//-(void)setValue:(CGFloat)value{
//    [self drawProgressBar:<#(CGSize)#> context:<#(CGContextRef)#>]
//}

- (void) drawInContext:(CGContextRef) context{
    [super drawInContext:context];
    
    UIGraphicsPushContext(context);
    
    CGRect rect = CGContextGetClipBoundingBox(context);
    rect = CGRectIntegral(CGRectInset(rect, self.borderPadding, self.borderPadding));
    
    [self drawEmptyBar:rect context:context];
    [self drawProgressBar:rect context:context];
    
    if (self.showValueString){
        [self drawText:rect context:context];
    }
    
    UIGraphicsPopContext();
}


- (void)drawEmptyPath:(CGContextRef)c myRect:(const CGRect *)myRect {
    UIBezierPath *path;
    if(self.isVertical) {
        path = [UIBezierPath bezierPathWithRoundedRect:*myRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii: CGSizeMake(self.progressLineWidth / 2, self.progressLineWidth / 2)];
    } else {
        path = [UIBezierPath bezierPathWithRoundedRect:*myRect cornerRadius: self.progressLineWidth / 2];
    }
    CGContextAddPath(c, path.CGPath);
    CGContextSetStrokeColorWithColor(c, self.emptyLineStrokeColor.CGColor);
    CGContextSetFillColorWithColor(c, self.emptyLineColor.CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
}

- (void)drawEmptyHorisontal:(CGContextRef)c rect:(const CGRect *)rect {
    CGRect myRect = CGRectMake(_margin, rect->size.height - self.progressLineWidth - _margin, rect->size.width - _margin * 2, self.progressLineWidth);
    [self drawEmptyPath:c myRect:&myRect];
}

- (void)drawEmptyLine:(CGContextRef)c rect:(const CGRect *)rect {
    
    if(self.isVertical) {
        [self drawEmptyVertical:c rect:rect];
    } else {
        [self drawEmptyHorisontal:c rect:rect];
    }
    
}

- (void)drawEmptyCircle:(CGContextRef)c rect:(const CGRect *)r {
    CGRect rect = *r;
    CGPoint center = {CGRectGetMidX(rect), CGRectGetMidY(rect)};
    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2;
    if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeOverlaysEmptyLine) {
        radius = radius - MAX(self.emptyLineWidth, self.progressLineWidth)/2.f;
    } else if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeAboveEmptyLine) {
        radius = radius - self.progressLineWidth - self.emptyLineWidth/2.f;
    } else {
        radius = radius - self.emptyLineWidth/2.f;
    }
    
    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathAddArc(arc, NULL,
                 center.x, center.y, radius,
                 (self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI,
                 -(self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI,
                 YES);
    
    
    CGPathRef strokedArc =
    CGPathCreateCopyByStrokingPath(arc, NULL,
                                   self.emptyLineWidth,
                                   (CGLineCap)self.emptyCapType,
                                   kCGLineJoinMiter,
                                   10);
    
    
    CGContextAddPath(c, strokedArc);
    CGContextSetStrokeColorWithColor(c, self.emptyLineStrokeColor.CGColor);
    CGContextSetFillColorWithColor(c, self.emptyLineColor.CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
    
    CGPathRelease(arc);
    CGPathRelease(strokedArc);
}

- (void)drawEmptyBar:(CGRect)rect context:(CGContextRef)c{
    
    if(self.emptyLineWidth <= 0){
        return;
    }
    
    if (self.isLine) {
        [self drawEmptyLine:c rect:&rect];
    } else {
        
        [self drawEmptyCircle:c rect:&rect];
    }
}

- (void)drawCircular:(CGContextRef)c center:(const CGPoint *)center radius:(CGFloat)radius {
    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathAddArc(arc, NULL,
                 center->x, center->y, radius,
                 (self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI-(2.f*M_PI)*(self.progressAngle/100.f)*(100.f-100.f*self.value/self.maxValue)/100.f,
                 -(self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI,
                 YES);
    
    CGPathRef strokedArc =
    CGPathCreateCopyByStrokingPath(arc, NULL,
                                   self.progressLineWidth,
                                   (CGLineCap)self.progressCapType,
                                   kCGLineJoinMiter,
                                   10);
    
    
    CGContextAddPath(c, strokedArc);
    CGContextSetFillColorWithColor(c, self.progressColor.CGColor);
    CGContextSetStrokeColorWithColor(c, self.progressStrokeColor.CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
    
    CGPathRelease(arc);
    CGPathRelease(strokedArc);
}

- (void)drawRoundedRextInContext:(CGContextRef)c myRect:(const CGRect *)myRect {
    UIBezierPath *path;
    if(self.isVertical) {
        path = [UIBezierPath bezierPathWithRoundedRect:*myRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii: CGSizeMake(self.progressLineWidth / 2, self.progressLineWidth / 2)];
    } else {
        path = [UIBezierPath bezierPathWithRoundedRect:*myRect cornerRadius: self.progressLineWidth / 2];
    }
    CGContextAddPath(c, path.CGPath);
    CGContextSetFillColorWithColor(c, self.progressColor.CGColor);
    CGContextSetStrokeColorWithColor(c, self.progressStrokeColor.CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
}

- (void)drawHorisontal:(CGContextRef)c rect:(const CGRect *)rect {
    if (self.value == 0) {
        return;
    }
    CGFloat value = self.value;
    if (value <= 4.0) {
        value = 4.0;
    }
    CGRect myRect = CGRectMake(_margin, rect->size.height - self.progressLineWidth - _margin, (rect->size.width - _margin * 2) * value / 100 , self.progressLineWidth);
    [self drawRoundedRextInContext:c myRect:&myRect];
}

- (void)drawEmptyVertical:(CGContextRef)c rect:(const CGRect *)rect {
    CGRect myRect;
    myRect.size = CGSizeMake(self.progressLineWidth,
                             rect->size.height - _margin * 2);
    if(self.anotationLeft) {
        myRect.origin = CGPointMake(rect->size.width - self.progressLineWidth,
                                    rect->size.height - _margin - myRect.size.height);
    } else {
        myRect.origin = CGPointMake(0,
                                    rect->size.height - _margin - myRect.size.height);
    }
}

- (void)drawVertical:(CGContextRef)c rect:(const CGRect *)rect {
    if (self.value == 0) {
        return;
    }
    CGFloat value = self.value;
    if (value <= 4.0) {
        value = 4.0;
    }
    CGRect myRect;
    myRect.size = CGSizeMake(self.progressLineWidth,
                             (rect->size.height - _margin * 2) * value / 100);
    if(self.anotationLeft) {
        myRect.origin = CGPointMake(rect->size.width - self.progressLineWidth, rect->size.height - _margin - myRect.size.height);
    } else {
        myRect.origin = CGPointMake(0,
                                    rect->size.height - _margin - myRect.size.height);
    }
    [self drawRoundedRextInContext:c myRect:&myRect];
    
}

- (void)drawLinear:(CGContextRef)c rect:(const CGRect *)rect {
    if(self.isVertical) {
        [self drawVertical:c rect:rect];
    } else {
        [self drawHorisontal:c rect:rect];
    }
}

- (void)drawProgressBar:(CGRect)rect context:(CGContextRef)c{
    if(self.progressLineWidth <= 0){
        return;
    }
    
    CGPoint center = {CGRectGetMidX(rect), CGRectGetMidY(rect)};
    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2;
    if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeOverlaysEmptyLine) {
        radius = radius - MAX(self.emptyLineWidth, self.progressLineWidth)/2.f;
    } else if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeAboveEmptyLine) {
        radius = radius - self.progressLineWidth/2.f;
    } else {
        radius = radius - self.emptyLineWidth - self.progressLineWidth/2.f;
    }
    
    if (self.isLine) {
        [self drawLinear:c rect:&rect];
    } else {
        [self drawCircular:c center:&center radius:radius];
        
    }
}

- (void)drawText:(CGRect)rect context:(CGContextRef)c{
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    CGFloat valueFontSize = self.valueFontSize == -1 ? CGRectGetHeight(rect)/5 : self.valueFontSize;
    
    NSDictionary* valueFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: self.valueFontName size:valueFontSize], NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    
    NSString *formatString = [NSString stringWithFormat:@"%%.%df", (int)self.decimalPlaces];
    
    NSString* textToPresent;
    if (self.countdown) {
        textToPresent = [NSString stringWithFormat:formatString, (self.maxValue - self.value)];
    } else {
        textToPresent = [NSString stringWithFormat:formatString, self.value];
    }
    NSAttributedString* value = [[NSAttributedString alloc] initWithString:textToPresent
                                                                attributes:valueFontAttributes];
    [text appendAttributedString:value];
    
    // set the decimal font size
    NSUInteger decimalLocation = [text.string rangeOfString:@"."].location;
    if (decimalLocation != NSNotFound){
        NSDictionary* valueDecimalFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: self.valueFontName size:self.valueDecimalFontSize == -1 ? valueFontSize : self.valueDecimalFontSize], NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};
        NSRange decimalRange = NSMakeRange(decimalLocation, text.length - decimalLocation);
        [text setAttributes:valueDecimalFontAttributes range:decimalRange];
    }
    
    // ad the unit only if specified
    if (self.showUnitString) {
        NSDictionary* unitFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: self.unitFontName size:self.unitFontSize == -1 ? CGRectGetHeight(rect)/7 : self.unitFontSize], NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};
        
        NSAttributedString* unit =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.unitString] attributes:unitFontAttributes];
        [text appendAttributedString:unit];
    }
    if(self.anotationTitle.length) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString: @"\n"
                                                                     attributes:valueFontAttributes]];
        valueFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12.0], NSForegroundColorAttributeName: [UIColor colorWithWhite:75.0/255.0 alpha:0.96], NSParagraphStyleAttributeName: textStyle};
        
        NSAttributedString* value = [[NSAttributedString alloc] initWithString: self.anotationTitle
                                                                    attributes: valueFontAttributes];
        [text appendAttributedString:value];
        
    }
    
    CGSize percentSize = [text size];
    CGPoint textCenter = [self textDrawingPointForSize:percentSize clippingRect:rect];
    [text drawAtPoint:textCenter];
}

- (CGPoint)textDrawingPointForSize:(CGSize)size clippingRect:(CGRect)rect {
    CGPoint textCenter;
    if(self.isLine && self.isVertical) {
        
        if(self.anotationLeft) {
            textCenter.x = _margin + self.progressLineWidth + _anotationOffset + size.width/2;
        } else {
            textCenter.x = CGRectGetWidth(rect) -  (_margin + self.progressLineWidth + _anotationOffset + size.width/2);
        }
        CGFloat min = size.height;
        CGFloat max = CGRectGetHeight(rect) - size.height;
        textCenter.y = MAX(min, MIN(rect.size.height - (rect.size.height - _margin * 2) * self.value / 100  - size.height/2, max));
        
    } else {
        textCenter = CGPointMake(
                                 CGRectGetMidX(rect)-size.width/2 + self.textOffset.x,
                                 CGRectGetMidY(rect)-size.height/2 + self.textOffset.y
                                 );
    }
    return textCenter;
    
}

#pragma mark - Override methods to support animations

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"value"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event{
    if ([self presentationLayer] != nil) {
        if ([event isEqualToString:@"value"]) {
            id animation = [super actionForKey:@"backgroundColor"];
            
            if (animation == nil || [animation isEqual:[NSNull null]])
            {
                [self setNeedsDisplay];
                return [NSNull null];
            }
            [animation setKeyPath:event];
            [animation setFromValue:[self.presentationLayer valueForKey:@"value"]];
            [animation setToValue:nil];
            return animation;
        }
    }
    
    return [super actionForKey:event];
}

@end
