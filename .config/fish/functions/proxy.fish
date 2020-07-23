
function proxy
    set -l MODE $argv[1]

    if test "$MODE" = "enable" -o "$MODE" = "e"
        set -l TMP_PROXY ""
        if test -z $PROXY
            read -p "set_color -o green; echo -n PROXY ; set_color normal; echo '> '" TMP_PROXY
        else
            read -p "set_color -o green; echo -n PROXY: $PROXY ; set_color normal; echo '> '" TMP_PROXY
        end

        if not test -z $TMP_PROXY
            set PROXY $TMP_PROXY
        end

        if not test -z $PROXY
            echo "proxy enable: $PROXY"
            set -gx http_proxy "$PROXY"
            set -gx https_proxy "$PROXY"
            set -gx ftp_proxy "$PROXY"
            set -gx no_proxy '127.0.0.1,localhost,host.docker.internal'

            set -gx HTTP_PROXY "$PROXY"
            set -gx HTTPS_PROXY "$PROXY"
            set -gx FTP_PROXY "$PROXY"
            set -gx NO_PROXY '127.0.0.1,localhost,host.docker.internal'
        end
    else if test "$MODE" = "disable" -o "$MODE" = "d"
        echo "proxy disable"
        unset_proxy
    end
end

function unset_proxy
    set -e http_proxy
    set -e https_proxy
    set -e ftp_proxy
    set -e no_proxy

    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e FTP_PROXY
    set -e NO_PROXY
end
