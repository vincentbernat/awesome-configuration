// Preferences for Firefox. To be symlinked in the profile as user.js.
// Settings synced through Firefox Accounts may not be present.

// Ensure context menus stay open after left-click (useful when scale
// == 1.5)
user_pref("ui.context_menus.after_mouseup", true);

// Don't display menubar when pressing Alt
user_pref("ui.key.menuAccessKeyFocuses", false);

// No popup at all!
user_pref("browser.link.open_newwindow.restriction", 0);

// Search settings
user_pref("browser.search.region", "FR");
user_pref("browser.search.suggest.enabled", false);

// Homepage is newtab. On launch, restore session.
user_pref("browser.startup.homepage", "about:newtab");
user_pref("browser.startup.page", 3);

// Languages
user_pref("intl.accept_languages", "en-us,en,fr");

// Disable pocket
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("extensions.pocket.enabled", false);

// Don't recommend extensions
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.discovery.enabled", false);

// Backspace is like back
user_pref("browser.backspace_action", 0);

// Don't allow detaching a tab by pulling it
user_pref("browser.tabs.allowTabDetach", false);

// Don't display fullscreen warning
user_pref("full-screen-api.warning.timeout", 0);
user_pref("full-screen-api.transition.timeout", 0);

// Don't autoplay videos (even without audio)
user_pref("media.autoplay.default", 5);

// Remove some annoying animations (notably when going full screen)
user_pref("toolkit.cosmeticAnimations.enabled", false);

// Force enable WebRender
user_pref("gfx.webrender.all", true);

// Enable AVIF
user_pref("image.avif.enabled", true);

// Lazy loading is too late on Firefox. See https://bugzilla.mozilla.org/show_bug.cgi?id=1618240
// Should be fixed in Firefox 84.
user_pref("dom.image-lazy-loading.root-margin.bottom.percentage", true);
user_pref("dom.image-lazy-loading.root-margin.bottom", 100);
user_pref("dom.image-lazy-loading.root-margin.top.percentage", true);
user_pref("dom.image-lazy-loading.root-margin.top", 50);

// Enable color scheme selector in devtools
user_pref("devtools.inspector.color-scheme-simulation.enabled", true);

// Disable DoH for now
user_pref("network.trr.mode", 5);
// No HTTP/3 yet (disabled by default, but document here it doesn't work well for me on Google)
user_pref("network.http.http3.enabled", false);
