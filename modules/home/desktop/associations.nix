{ lib, ... }: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "application/zip" = "org.kde.ark.desktop";
      "application/x-7z-compressed" = "org.kde.ark.desktop";
      "application/x-tar" = "org.kde.ark.desktop";
      "application/gzip" = "org.kde.ark.desktop";
      "application/x-xz" = "org.kde.ark.desktop";
      "application/zstd" = "org.kde.ark.desktop";
      "x-scheme-handler/spotify" = "spotify.desktop";
      "text/calendar" = "dev.duxlabs.calendar.desktop";
      "x-scheme-handler/webcal" = "dev.duxlabs.calendar.desktop";
      "x-scheme-handler/webcals" = "dev.duxlabs.calendar.desktop";
    } // lib.genAttrs [
      "image/png" "image/jpeg" "image/gif" "image/webp"
      "image/svg+xml" "image/bmp" "image/tiff"
    ] (_: "org.gnome.Loupe.desktop")
    // lib.genAttrs [
      "text/plain" "text/markdown" "text/csv" "text/xml"
      "application/json" "application/xml"
    ] (_: "org.gnome.TextEditor.desktop")
    // lib.genAttrs [
      "application/pdf" "application/epub+zip" "application/x-cbz"
      "application/x-cbr" "image/vnd.djvu"
    ] (_: "org.gnome.Papers.desktop")
    // lib.genAttrs [
      "text/html" "application/xhtml+xml" "application/x-extension-htm"
      "application/x-extension-html" "application/x-extension-shtml"
      "application/x-extension-xht" "application/x-extension-xhtml"
      "x-scheme-handler/http" "x-scheme-handler/https" "x-scheme-handler/chrome"
    ] (_: "firefox.desktop");
  };
}
