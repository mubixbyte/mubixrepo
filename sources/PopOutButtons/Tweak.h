#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <math.h>
#import <rootless.h>
#import <sys/utsname.h>
#import <Foundation/NSDistributedNotificationCenter.h>

// libGcUniversal is loaded on-device through the package dependency. Keeping
// this declaration local lets a clean Theos environment compile the tweak.
@interface GcColorPickerUtils : NSObject
+ (UIColor *)colorFromDefaults:(NSString *)defaults
                       withKey:(NSString *)key
                      fallback:(NSString *)fallback;
@end

// static UIColor* returnUIColorForHex(NSString *hexString) { //thx gpt
//     if ([hexString hasPrefix:@"#"]) {
//         hexString = [hexString substringFromIndex:1];
//     } else if ([hexString hasPrefix:@"0x"]) {
//         hexString = [hexString substringFromIndex:2];
//     }
    
//     NSUInteger length = [hexString length];
//     if (length != 6 && length != 8) {
//         return nil; 
//     }
    
//     unsigned rgbValue = 0;
//     NSScanner *scanner = [NSScanner scannerWithString:hexString];
//     if (![scanner scanHexInt:&rgbValue]) {
//         return nil;
//     }
    
//     CGFloat red, green, blue, alpha;
//     if (length == 6) {
//         red = ((rgbValue & 0xFF0000) >> 16) / 255.0;
//         green = ((rgbValue & 0x00FF00) >> 8) / 255.0;
//         blue = (rgbValue & 0x0000FF) / 255.0;
//         alpha = 1.0;
//     } else {
//         red = ((rgbValue & 0xFF000000) >> 24) / 255.0;
//         green = ((rgbValue & 0x00FF0000) >> 16) / 255.0;
//         blue = ((rgbValue & 0x0000FF00) >> 8) / 255.0;
//         alpha = (rgbValue & 0x000000FF) / 255.0;
//     }
    
//     return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
// }

@interface UIDevice (PopOutButtons)
+ (NSString *)_pob_deviceMachine;
@end

@interface CALayer (Undocumented)
@property (atomic, assign) unsigned int disableUpdateMask;
@end

@interface UIWindow (Undocumented)
- (void)setAutorotates:(BOOL)autorotates forceUpdateInterfaceOrientation:(BOOL)forceUpdateInterfaceOrientation;
- (void)setAutorotates:(BOOL)autorotates;
- (void)_rotateWindowToOrientation:(NSInteger)orientation updateStatusBar:(BOOL)updateStatusBar duration:(CGFloat)duration skipCallbacks:(BOOL)skipCallbacks;
@end

@interface UIScreen (Undocumented)
@property (nonatomic, assign) CGRect _referenceBounds;
@end

@interface UIBezierPath (Undocumented)
- (void)_addRoundedCornerWithTrueCorner:(CGPoint)cornerPoint radius:(CGSize)radius corner:(NSUInteger)corner clockwise:(BOOL)clockwise leadInIsContinuous:(BOOL)leadInIsContinuous leadOutIsContinuous:(BOOL)leadOutIsContinuous;
@end 

@interface SBHUDWindow : UIWindow
- (void)_pob_setHUDShiftOut:(BOOL)shift;
@end

@interface SBSecureWindow : UIWindow
- (instancetype)initWithScreen:(UIScreen *)screen debugName:(NSString *)name;
- (instancetype)initWithScreen:(UIScreen *)screen role:(id)role debugName:(NSString *)name;
- (instancetype)initWithWindowScene:(UIWindowScene *)scene role:(id)role debugName:(NSString *)name;
- (instancetype)initWithScreen:(UIScreen *)screen debugName:(NSString *)debugName rootViewController:(UIViewController *)rootViewController;
@end

@interface SBFTouchPassThroughViewController : UIViewController
@end

@interface POBShapeLayer : CAShapeLayer
@property (nonatomic, strong) UIBezierPath *showingPath;
@property (nonatomic, strong) UIBezierPath *hidingPath;
@property (nonatomic, assign) BOOL isBackwards;
@property (nonatomic, assign) CGFloat curvedness;
@property (nonatomic, strong) NSTimer *waitToRemoveBorderTimer;
@property (nonatomic, assign) CGFloat defaultLineWidth;
@property (nonatomic, assign) BOOL isShowing;
- (void)setBorderWithShowing:(BOOL)showing;
- (void)removeBorderWithTimer:(NSTimer *)timer;
- (void)updateStateWithShowing:(BOOL)showing;
- (void)updatePathsWithFrame:(CGRect)frame hidden:(BOOL)startHidden;
@end

@interface POBWindow : SBSecureWindow
@end

@interface SBVolumeButtonEventMapper : NSObject
@property (nonatomic, assign) NSInteger effectiveInterfaceOrientation;
@end

@interface SpringBoard : UIApplication
@property (nonatomic, retain) POBWindow *_pobWindow;
@property (nonatomic, retain) SBHUDWindow *_pob_SBHUDWindow;
- (SBVolumeButtonEventMapper *)volumeButtonEventMapper;
@end

@interface POBRootViewContoller : SBFTouchPassThroughViewController
@property (nonatomic, strong) POBShapeLayer *volUpLayer;
@property (nonatomic, strong) POBShapeLayer *volDownLayer;
@property (nonatomic, strong) POBShapeLayer *lockButtonLayer;
@property (nonatomic, assign) CGFloat volUpDefaultY;
@property (nonatomic, assign) CGFloat volDownDefaultY;
@property (nonatomic, assign) CGFloat lockButtonDefaultY;
@property (nonatomic, strong) NSTimer *hidePopoutsTimer;
- (void)handlePrefsUpdateWithNotification:(NSNotification *)notification;
- (void)handlePrefsUpdate;
@end

@interface SBVolumeControl : NSObject
@end

@interface SBHUDController : NSObject
- (SBHUDWindow *)HUDWindow; // ios 17+
- (SBHUDWindow *)hudWindow; // ios <17 🤦‍♂️
- (BOOL)anyHUDsVisible;
@end

@interface SBLockHardwareButton : NSObject
- (BOOL)isButtonDown;
@end
