function fixaudio
    set card (pactl list cards short | awk '/00_1f/ {print $2; exit}')
    set prof (pactl list cards | grep -o 'HiFi ([^)]*Speaker[^)]*)' | head -1)
    if test -z "$card"; or test -z "$prof"
        echo "No encontré la tarjeta o el perfil con Speaker"
        return 1
    end
    pactl set-card-profile $card "$prof"; and echo "Audio: $prof"
end
