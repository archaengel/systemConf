{ ... }:
{
  programs.qutebrowser = {
    enable = true;
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
    };
  };
}
