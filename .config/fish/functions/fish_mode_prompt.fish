# Display the current binding mode... if it's vi or vi-like.
#
# To always show the binding mode (regardless of current bindings):
#     set -g theme_display_vi yes
#
# To never show:
#     set -g theme_display_vi no

function fish_mode_prompt -d 'bobthefish-optimized fish mode indicator'
    [ "$theme_display_vi" != 'no' ]
    or return

    [ "$fish_key_bindings" = 'fish_vi_key_bindings' \
        -o "$fish_key_bindings" = 'hybrid_bindings' \
        -o "$fish_key_bindings" = 'fish_hybrid_key_bindings' \
        -o "$theme_display_vi" = 'yes' ]
    or return

    __bobthefish_colors $theme_color_scheme

    type -q bobthefish_colors
    and bobthefish_colors

    set_color normal # clear out anything bold or underline...

    switch $fish_bind_mode
        case default
            set_color -b 0288d1 white --bold
            echo -n ' NORMAL '
        case insert
            set_color -b 00796b white --bold
            echo -n ' INSERT '
        case replace_one replace-one
            set_color -b c62828 white --bold
            echo -n ' REPLACE '
        case visual
            set_color -b d84315 white --bold
            echo -n ' VISUAL '
    end

    set_color normal
end
