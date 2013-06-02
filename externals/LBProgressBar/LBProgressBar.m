//
//  LBProgressBar.m
//  LBProgressBar
//
//  Created by Laurin Brandner on 05.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBProgressBar.h"

#define DEFAULT_radius 5
#define DEFAULT_angle 30

#define DEFAULT_inset 2
#define DEFAULT_stripeWidth 7

#define DEFAULT_barColor [NSColor colorWithCalibratedRed:25.0/255.0 green:29.0/255.0 blue:33.0/255.0 alpha:1.0]
#define DEFAULT_lighterProgressColor [NSColor colorWithCalibratedRed:0.543 green:0.024 blue:0.311 alpha:1.000]
#define DEFAULT_darkerProgressColor [NSColor colorWithCalibratedRed:0.378 green:0.104 blue:0.251 alpha:1.000]
#define DEFAULT_lighterStripeColor [NSColor colorWithCalibratedRed:0.379 green:0.015 blue:0.230 alpha:1.000]
#define DEFAULT_darkerStripeColor [NSColor colorWithCalibratedRed:0.392 green:0.111 blue:0.264 alpha:1.000]
#define DEFAULT_shadowColor [NSColor colorWithCalibratedRed:0.750 green:0.077 blue:0.476 alpha:1.000]

@implementation LBProgressBar

@synthesize progressOffset;

#pragma mark Accessors

-(void)setDoubleValue:(double)value {
    [super setDoubleValue:value];
    if (![self isDisplayedWhenStopped] && value == [self maxValue]) {
        [self stopAnimation:self];
    }
}

-(NSTimer*)animator {
    return animator;
}

-(void)setAnimator:(NSTimer *)value {
    if (animator != value) {
        [animator invalidate];
        animator = value;
    }
}

#pragma mark Initialization

-(id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.progressOffset = 0;
        self.animator = nil;
    }
    return self;
}

#pragma mark -
#pragma mark Memory

-(void)dealloc {
    self.progressOffset = 0;
    self.animator = nil;
}

#pragma mark -
#pragma mark Drawing

-(void)drawShadowInBounds:(NSRect)bounds {
    [DEFAULT_shadowColor set];
    
    NSBezierPath* shadow = [NSBezierPath bezierPath];
    
    [shadow moveToPoint:NSMakePoint(0, 2)];
    [shadow lineToPoint:NSMakePoint(NSWidth(bounds), 2)];
    
    [shadow stroke];
}

-(NSBezierPath*)stripeWithOrigin:(NSPoint)origin bounds:(NSRect)frame {
    
    float height = frame.size.height;
    
    NSBezierPath* rect = [[NSBezierPath alloc] init];
    
    [rect moveToPoint:origin];
    [rect lineToPoint:NSMakePoint(origin.x+DEFAULT_stripeWidth, origin.y)];
    [rect lineToPoint:NSMakePoint(origin.x+DEFAULT_stripeWidth-8, origin.y+height)];
    [rect lineToPoint:NSMakePoint(origin.x-8, origin.y+height)];
    [rect lineToPoint:origin];
    
    return rect;
}

-(void)drawStripesInBounds:(NSRect)frame {
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:DEFAULT_lighterStripeColor endingColor:DEFAULT_darkerStripeColor];
    NSBezierPath* allStripes = [[NSBezierPath alloc] init];
    
    for (int i = 0; i <= frame.size.width/(2*DEFAULT_stripeWidth)+(2*DEFAULT_stripeWidth); i++) {
        NSBezierPath* stripe = [self stripeWithOrigin:NSMakePoint(i*2*DEFAULT_stripeWidth+self.progressOffset, DEFAULT_inset) bounds:frame];
        [allStripes appendBezierPath:stripe];
    }
    
    //clip
    NSBezierPath* clipPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    [clipPath addClip];
    [clipPath setClip];
    
    if (clipPath.isEmpty)
        NSLog(@"empty");
    
    [gradient drawInBezierPath:allStripes angle:0];
}

-(void)drawBezel {
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);
    
    CGFloat maxX = NSMaxX(self.bounds);
    
    //white shadow
    NSBezierPath* shadow = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0.5, 0, self.bounds.size.width-1, self.bounds.size.height-1) xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    NSRect clipRect = NSMakeRect(0, self.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height/2);
    [NSBezierPath clipRect:clipRect];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
    [shadow stroke];
    
    CGContextRestoreGState(context);
    
    //rounded rect
    NSBezierPath* roundedRect = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-1) xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    [DEFAULT_barColor set];
    [roundedRect fill];
    
    //inner glow
    CGMutablePathRef glow = CGPathCreateMutable();
    CGPathMoveToPoint(glow, NULL, DEFAULT_radius, 0);
    CGPathAddLineToPoint(glow, NULL, maxX-DEFAULT_radius, 0);
    
    [[NSColor colorWithCalibratedRed:17.0/255.0 green:20.0/255.0 blue:23.0/255.0 alpha:1.0] set];
    CGContextAddPath(context, glow);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(glow);
}

-(void)drawProgressWithBounds:(NSRect)frame {
    if (frame.size.width <= 0)
        return;
    NSBezierPath* bounds = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:DEFAULT_radius yRadius:DEFAULT_radius];
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:DEFAULT_lighterProgressColor endingColor:DEFAULT_darkerProgressColor];
    [gradient drawInBezierPath:bounds angle:0];
}

-(void)drawRect:(NSRect)dirtyRect {
    
    self.progressOffset = (self.progressOffset > (2*DEFAULT_stripeWidth)-1) ? 0 : ++self.progressOffset;
    
    float distance = [self maxValue]-[self minValue];
    float value = ([self doubleValue]) ? [self doubleValue]/distance : 0;
    
    [self drawBezel];
    
    if (value) {
        NSRect frame = self.frame;
        CGFloat width = ((frame.size.width / self.maxValue) * (value * 100)) - DEFAULT_inset;
        //NSRect bounds = NSMakeRect(DEFAULT_inset, DEFAULT_inset, (frame.size.width * value) - (2 * DEFAULT_inset), (frame.size.height-2*DEFAULT_inset)-1);
        NSRect bounds = NSMakeRect(DEFAULT_inset, DEFAULT_inset, width, (frame.size.height-2*DEFAULT_inset)-1);
        
        [self drawProgressWithBounds:bounds];
        [self drawStripesInBounds:bounds];
        [self drawShadowInBounds:bounds];
    }
}

#pragma mark -
#pragma mark Actions

-(void)startAnimation:(id)sender {
    if (!self.animator) {
        self.animator = [NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(activateAnimation:) userInfo:nil repeats:YES];
    }
}

-(void)stopAnimation:(id)sender {
    self.animator = nil;
}

-(void)activateAnimation:(NSTimer*)timer {
    [self setNeedsDisplay:YES];
}

#pragma mark -

@end
