#import "UtilPlugin.h"
#if __has_include(<util/util-Swift.h>)
#import <util/util-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "util-Swift.h"
#endif

@implementation UtilPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUtilPlugin registerWithRegistrar:registrar];
}
@end
