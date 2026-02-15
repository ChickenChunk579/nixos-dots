{
  self,
  pkgs,
  ...
}:
{
  programs.wofi.enable = true;
  programs.wofi.settings = {
    mode = "drun";
    width = 500;
    height = 400;
    location = "center";
    orientation = "vertical";

    allow_markup = true;
    allow_images = true;
    image_size = 30;
  };
  programs.wofi.style = ''
    @import url(".config/matugen/colors.css");

    #window {
        margin: 0px;
        background-color: transparent;
        /* Change this to a visible color like @dark-on-background */
        color: @dark-on-background; 
    }
    #outer-box {
        margin: 0px;
        border-radius: 18px;
        background-color: alpha(@dark-background, 1.0);
        /* This ensures the inner content follows the rounding */
        border: none; 
    }

    #input {
        margin: 10px;
        background-color: alpha(@dark-on-secondary-fixed-variant, 0.7);
        color: @dark-on-background;
        border-radius: 25px;
        border: 0px solid #83a598;
    }

    #scroll {
        margin-bottom: 15px;
    }

    #text {
        color: @dark-on-background;
    }


    #entry {
        margin: 0px 10px;
    }

    #entry:selected {
        background-color: alpha(@dark-primary, 1.0);
        color: @dark-background;
        border-radius: 10px;
        border: none;
        outline: none;
    }

    #entry > box {
        margin-left: 16px;
    }


    #entry image {
        padding-right: 10px;
    }
  '';
}

