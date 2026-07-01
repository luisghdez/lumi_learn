#import "LocalNotificationsPluginRegistrant.h"
#import "GeneratedPluginRegistrant.h"

static void PluginRegistrantCallback(NSObject<FlutterPluginRegistry>* registry) {
    [GeneratedPluginRegistrant registerWithRegistry:registry];
}

@implementation LocalNotificationsPluginRegistrant

+ (void)setPluginRegistrantCallback {
    Class pluginClass = NSClassFromString(@"FlutterLocalNotificationsPlugin");
    SEL selector = @selector(setPluginRegistrantCallback:);

    if (!pluginClass || ![pluginClass respondsToSelector:selector]) {
        return;
    }

    void (*setCallback)(id, SEL, FlutterPluginRegistrantCallback) = (void *)[pluginClass methodForSelector:selector];
    setCallback(pluginClass, selector, PluginRegistrantCallback);
}

@end
