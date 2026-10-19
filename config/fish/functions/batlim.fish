function batlim
    set sysfs /sys/bus/wmi/drivers/acer-wmi-battery/health_mode
    switch "$argv[1]"
        case on
            echo 1 > $sysfs; and echo "Límite 80%: ON"
        case off
            echo 0 > $sysfs; and echo "Límite 80%: OFF (carga hasta 100%)"
        case '*'
            if test (cat $sysfs) = 1
                echo "Límite 80%: ON"
            else
                echo "Límite 80%: OFF"
            end
            echo "Uso: batlim on | batlim off"
    end
end
