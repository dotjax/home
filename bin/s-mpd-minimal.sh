#!/bin/bash

cat > ~/.mpd/mpd.conf <<EOF
music_directory "/run/media/jacob/storage/music"
bind_to_address "127.0.0.1"
port "6600"

db_file "~/.mpd/mpd.db"
log_file "~/.mpd/mpd.log"
state_file "~/.mpd/state"

audio_output {
    type "pipewire"
    name "PipeWire"
}

audio_output {
    type            "fifo"
    name            "my_fifo"
    path            "/tmp/mpd.fifo"
    format          "44100:16:2"
}
EOF

mkdir -p ~/.local/state/mpd

systemctl --user restart mpd
systemctl --user status mpd --no-pager
