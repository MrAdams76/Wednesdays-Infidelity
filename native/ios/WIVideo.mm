#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#include "WIVideo.h"
#include <string>

// UIKit and Haxe's iOS frame loop run on the main thread. Completion is polled
// from Haxe so no Objective-C callback calls into the Haxe GC from another thread.
static AVPlayer *wiPlayer = nil;
static UIView *wiOverlay = nil;
static id wiCompletion = nil;
static int wiStatus = 0;
static bool wiRepeat = false;

@interface WIVideoView : UIView
@end
@implementation WIVideoView
+ (Class)layerClass { return [AVPlayerLayer class]; }
- (void)skip:(UITapGestureRecognizer *)gesture { wiStatus = 2; }
@end

void wi_video_dispose()
{
    if (wiCompletion != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:wiCompletion];
#if !__has_feature(objc_arc)
        [wiCompletion release];
#endif
        wiCompletion = nil;
    }
    [wiPlayer pause];
    [wiOverlay removeFromSuperview];
    ((AVPlayerLayer *)wiOverlay.layer).player = nil;
#if !__has_feature(objc_arc)
    [wiPlayer release];
    [wiOverlay release];
#endif
    wiPlayer = nil;
    wiOverlay = nil;
    wiStatus = 0;
}

void wi_video_play(const char *path, bool skippable, bool repeat)
{
    wi_video_dispose();
    NSString *relative = [NSString stringWithUTF8String:path];
    NSString *file = relative;
    if (![file isAbsolutePath]) file = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:relative];
    // Lime's iOS resource folder prefixes manifest paths with "assets/".
    if (![[NSFileManager defaultManager] fileExistsAtPath:file] && ![relative isAbsolutePath])
        file = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"assets"] stringByAppendingPathComponent:relative];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) { wiStatus = -1; return; }
    UIWindow *window = nil;
    for (UIWindow *candidate in [UIApplication sharedApplication].windows)
        if (candidate.isKeyWindow) { window = candidate; break; }
    if (window == nil) { wiStatus = -1; return; }

    wiPlayer = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:file]];
    wiOverlay = [[WIVideoView alloc] initWithFrame:window.bounds];
    wiOverlay.backgroundColor = [UIColor blackColor];
    wiOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    AVPlayerLayer *layer = (AVPlayerLayer *)wiOverlay.layer;
    layer.player = wiPlayer;
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [window addSubview:wiOverlay];
    if (skippable) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:wiOverlay action:@selector(skip:)];
        [wiOverlay addGestureRecognizer:tap];
#if !__has_feature(objc_arc)
        [tap release];
#endif
    }
    wiRepeat = repeat;
    wiCompletion = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
        object:wiPlayer.currentItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            if (wiRepeat) {
                [wiPlayer seekToTime:kCMTimeZero];
                [wiPlayer play];
            } else wiStatus = 2;
        }];
#if !__has_feature(objc_arc)
    [wiCompletion retain];
#endif
    [wiPlayer play];
}

int wi_video_status()
{
    if (wiStatus == 2 || wiStatus == -1) return wiStatus;
    if (wiPlayer.currentItem.status == AVPlayerItemStatusFailed) return -1;
    if (wiPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) return 1;
    return 0;
}
void wi_video_pause() { [wiPlayer pause]; }
void wi_video_resume() { [wiPlayer play]; }
void wi_video_volume(double value) { wiPlayer.volume = (float)value; }

static std::string wiMenuCode;
static bool wiMenuCodeReady = false;
static bool wiMenuCodeOpen = false;
void wi_menu_code_open()
{
    if (wiMenuCodeOpen) return;
    UIWindow *window = nil;
    for (UIWindow *candidate in [UIApplication sharedApplication].windows)
        if (candidate.isKeyWindow) { window = candidate; break; }
    UIViewController *controller = window.rootViewController;
    while (controller.presentedViewController != nil) controller = controller.presentedViewController;
    if (controller == nil) return;
    wiMenuCodeOpen = true;
    wiMenuCodeReady = false;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Menu code" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        wiMenuCodeOpen = false;
    }]];
    __unsafe_unretained UIAlertController *codeAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:@"Enter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *text = [codeAlert.textFields.firstObject.text uppercaseString];
        wiMenuCode = text.UTF8String != NULL ? text.UTF8String : "";
        wiMenuCodeReady = true;
        wiMenuCodeOpen = false;
    }]];
    [controller presentViewController:alert animated:YES completion:nil];
}
const char *wi_menu_code_poll()
{
    if (!wiMenuCodeReady) return NULL;
    wiMenuCodeReady = false;
    return wiMenuCode.c_str();
}
