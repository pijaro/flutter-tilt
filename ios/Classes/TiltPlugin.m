#import "TiltPlugin.h"
#if __has_include(<tilt/tilt-Swift.h>)
#import <tilt/tilt-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tilt-Swift.h"
#endif

@implementation TiltPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTiltPlugin registerWithRegistrar:registrar];
}
@end
