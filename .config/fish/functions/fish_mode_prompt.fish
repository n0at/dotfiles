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

    set color_path_bg $color_path[1]
    set black 262a33
    set normal 42a5f5
    set insert 00e676
    set replace ef5350
    set visual f9a825

    switch $fish_bind_mode
        case default
            set_color -b $black $normal --bold
            echo -n ''
            set_color -b $normal $color_path_bg --bold
            echo -n ' '
        case insert
            set_color -b $black $insert --bold
            echo -n ''
            set_color -b $insert $color_path_bg --bold
            echo -n ' '
        case replace_one replace-one
            set_color -b $black $replace --bold
            echo -n ''
            set_color -b $replace $color_path_bg --bold
            echo -n ' '
        case visual
            set_color -b $black $visual --bold
            echo -n ''
            set_color -b $visual $color_path_bg --bold
            echo -n ' '
    end

    set_color normal
end
