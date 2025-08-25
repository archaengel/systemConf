{ pkgs, ... }:
{
  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    package = pkgs.qutebrowser.override {
      enableWideVine = true;
    };
    searchEngines = {
      DEFAULT = "https://google.com/search?udm=14&q={}";
      ddg = "https://duckduckgo.com/?q={}";
      gh = "https://github.com/search?type=code&q={}";
    };
    settings = {
      tabs.position = "bottom";
      colors.webpage = {
        darkmode.enabled = false;
        preferred_color_scheme = "dark";
      };
      url.default_page = "https://google.com";
      editor.command = [
        "ghostty"
        "-e"
        "nvim"
        "{file}"
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
  };
}
