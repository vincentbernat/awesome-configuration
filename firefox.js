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

// Backspace is like back
user_pref("browser.backspace_action", 0);

// Ctrl-Tab should not use recent order (it's confusing for me)
user_pref("browser.ctrlTab.recentlyUsedOrder", false);
// Don't allow detaching a tab by pulling it
user_pref("browser.tabs.allowTabDetach", false);

// Don't display fullscreen warning
user_pref("full-screen-api.warning.timeout", 0);
user_pref("full-screen-api.transition.timeout", 0);

// Don't autoplay videos (even without audio)
user_pref("media.autoplay.default", 5);

// Remove some annoying animations (notably when going full screen)
user_pref("toolkit.cosmeticAnimations.enabled", false);

// Do not force-enable hardware compositing and WebRender.
user_pref("layers.acceleration.force-enabled", false);
user_pref("gfx.webrender.enabled", false);
user_pref("gfx.webrender.all", false);

// Disable DoH for now
user_pref("network.trr.mode", 5);
