{ pkgs, ... }: {
  programs.sioyek = {
    enable = true;
    config = {
      custom_background_color = "0.1176 0.1176 0.1804";
      custom_text_color = "0.8039 0.8392 0.9569";
    };
  };
}
