{ pkgs, username, ... }:
{
  programs.jujutsu = {
    enable = true;
    ediff = pkgs.lib.mkForce false;
    settings = {
      user = {
        name = username;
        email = "god11341258@gmail.com";
      };
      ui = {
        default-command = [
          "log"
          "--no-pager"
        ];
        pager = "delta";
        diff-formatter = ":git";
      };
      template-aliases = {
        "slugify(str)" = ''
          truncate_end(
            65,
            str.first_line()
              .replace(regex:'[^[[:alnum:]].]', '-')
              .replace(regex:'-{2,}', '-')
              .replace(regex:'\.{2,}', '.')
              .replace(regex:'(^-+|-+$)', ''')
              .lower()
          )
        '';
      };
      templates = {
        git_push_bookmark = ''
          "archaengel/" ++ slugify(description) ++ "/" ++ change_id.short()
        '';
      };
      aliases = {
        # yoinked from https://radicle.xyz/2025/08/14/jujutsu-with-radicle
        tug = [
          "bookmark"
          "move"
          "--from"
          "closest_bookmark(@)"
          "--to"
          "closest_pushable(@)"
        ];
      };
      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "closest_pushable(to)" =
          "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
        "desc(x)" = "description(x)";
        "pending()" = ".. ~ ::tags() ~ ::remote_bookmarks() ~ @ ~ private()";
        "private()" =
          "description(glob:'wip:*') | description(glob:'private:*') | description(glob:'WIP:*') | description(glob:'PRIVATE:*') | conflicts() | (empty() ~ merges()) | description('substring-i:\"DO NOT MAIL\"')";
      };
    };
  };
}
