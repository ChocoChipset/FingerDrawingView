#import "FingerDrawingView.h"
#import <QuartzCore/QuartzCore.h>


#define k8BITS 8
#define kSTROKE_WIDTH 3.0

// Private properties and methods

@interface FingerDrawingView ()

static CGPoint CGPointMid (CGPoint a, CGPoint b);
-(void)commonInitialization;
-(void)createNewCachedContext;
-(void)drawCacheWithTouch:(UITouch *)aNewTouch;

@property (retain) UIImage *imageRef;
@property (assign) CGContextRef cachedContext;
@end

@implementation FingerDrawingView

@synthesize imageRef, cachedContext;

#pragma mark - View Life Cycle

-(id)init
{
    self = [super init];
    if (self) 
    {
        [self commonInitialization];
    }
    return self;
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self commonInitialization];
    }
    return self;
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self commonInitialization];        
    }
    return self;
}



-(void)commonInitialization
{
    self.multipleTouchEnabled = NO;
    [self createNewCachedContext];
}

- (void)releaseCachedContext
{
    if (self.cachedContext != NULL)
    {
        CGContextRelease(self.cachedContext);
    }
}

-(void)dealloc
{
    [self releaseCachedContext];
    [imageRef release];
    [super dealloc];
}

#pragma mark - Drawing Stuff

-(void)createNewCachedContext
{
    int bitmapBytesPerRow = (self.frame.size.width * 4);
 
    [self releaseCachedContext];
    
    self.cachedContext = CGBitmapContextCreate (NULL,
                                               self.frame.size.width,
                                               self.frame.size.height,
                                               k8BITS,
                                               bitmapBytesPerRow,
                                               CGColorSpaceCreateDeviceRGB(),
                                               kCGImageAlphaPremultipliedLast);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(self.cachedContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);

}

-(void)drawCacheWithTouch:(UITouch *)theTouch
{                                           
    CGPoint lastPoint = [theTouch previousLocationInView:self];
    CGPoint newPoint = [theTouch locationInView:self];
    CGPoint midPoint = CGPointMid(lastPoint, newPoint);

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = kSTROKE_WIDTH;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [bezierPath moveToPoint:lastPoint];
    [bezierPath addQuadCurveToPoint:midPoint controlPoint:newPoint];
    [bezierPath addLineToPoint:newPoint];
    
    float strokeWidthTwice = kSTROKE_WIDTH*2;
    
    CGRect firstDrawingArea = CGRectMake(lastPoint.x-kSTROKE_WIDTH,
                                         lastPoint.y-kSTROKE_WIDTH,
                                         strokeWidthTwice,
                                         strokeWidthTwice);
    
    CGRect lastDrawingArea = CGRectMake(newPoint.x-kSTROKE_WIDTH,
                                        newPoint.y-kSTROKE_WIDTH,
                                            strokeWidthTwice,
                                        strokeWidthTwice);
    
    CGRect totalDrawingArea = CGRectUnion(firstDrawingArea, lastDrawingArea);
    
    UIGraphicsPushContext(self.cachedContext);

    [bezierPath stroke];

    UIGraphicsPopContext();

    [self setNeedsDisplayInRect:totalDrawingArea];
}


#pragma mark - Drawing Export, Etc

-(void)clearDrawings
{
    [self createNewCachedContext];
    [self setNeedsDisplay];
}


-(UIImage *)imageOfDrawings
{
    UIImage *result = nil;
    
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

#pragma mark - Gesture Recognizers

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *theTouch = [touches anyObject];    // view is not multitouch, anyObject will retrieve THAT touch
    
    [self drawCacheWithTouch:theTouch];
    
}

#pragma mark - Static functions

static CGPoint CGPointMid (CGPoint a, CGPoint b)
{
    return CGPointMake((a.x + b.x) / 2, (a.y + b.y) / 2);
}


@end
