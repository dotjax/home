#!/bin/bash
# A simple script to reload, clean, and restart the user's systemd services.

systemctl --user daemon-reload
systemctl --user reset-failed
systemctl --user restart default.target