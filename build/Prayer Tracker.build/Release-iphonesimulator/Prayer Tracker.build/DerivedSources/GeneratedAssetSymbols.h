#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.johnmark.prayertracker";

/// The "appTint" asset catalog color resource.
static NSString * const ACColorNameAppTint AC_SWIFT_PRIVATE = @"appTint";

/// The "icon_alternative" asset catalog image resource.
static NSString * const ACImageNameIconAlternative AC_SWIFT_PRIVATE = @"icon_alternative";

#undef AC_SWIFT_PRIVATE
