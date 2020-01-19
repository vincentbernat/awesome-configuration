-- Start idempotent commands
local execute = {
   -- Default browser
   "xdg-mime default " .. config.browser .. ".desktop " ..
      "x-scheme-handler/http " ..
      "x-scheme-handler/https " ..
      "text/html",
   -- Default MIME types
   "xdg-mime default org.gnome.Evince.desktop application/pdf",
   "xdg-mime default gpicview.desktop image/png image/x-apple-ios-png image/jpeg image/jpg image/gif"
}

os.execute(table.concat(execute, ";"))
