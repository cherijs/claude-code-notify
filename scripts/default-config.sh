# Claude Code Notify Configuration
# Location: ~/.claude/notify/config

# Enable/disable notifications globally
# Use /notify:toggle-global to toggle, or set manually
NOTIFY_ENABLED="true"

# Sound file to play (optional, platform-specific)
# Leave empty to use platform default:
#   macOS:   /System/Library/Sounds/Hero.aiff
#   Linux:   /usr/share/sounds/freedesktop/stereo/complete.oga
#   Windows: C:\Windows\Media\chimes.wav
#
# macOS options: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink
# Example: NOTIFY_SOUND="/System/Library/Sounds/Glass.aiff"
#
NOTIFY_SOUND=""

# Tmux speech settings (cross-platform)
# When enabled in tmux, speaks the window name/number instead of playing sound
# Requires: macOS (say), Linux (espeak or spd-say), Windows (PowerShell)
NOTIFY_TMUX_SPEECH="false"

# Voice for speech
# macOS: run `say -v '?'` to list (e.g., Samantha, Alex, Daniel)
# Linux espeak: run `espeak --voices` to list (e.g., en, en-us, en-gb)
# Linux spd-say: run `spd-say -L` to list
# Windows: run `PowerShell -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | % { $_.VoiceInfo.Name }"`
NOTIFY_TMUX_VOICE="Samantha"

# Speech rate (words per minute, default 350)
# macOS: passed to `say -r`
# Linux espeak: passed to `espeak -s`
# Linux spd-say: converted to spd-say rate scale
NOTIFY_TMUX_SPEECH_RATE=350

# What to announce: "auto", "number", or "name"
#   auto   - uses number for default shell names (fish, bash, zsh, etc.), name otherwise
#   number - always use window number
#   name   - always use window name
NOTIFY_TMUX_SPEECH_PREFER="auto"

# What to say for numbered windows (use {n} for window number)
# Examples: "Window {n}", "{n}", "Tab {n}", "Pane {n}"
NOTIFY_TMUX_WINDOW_PATTERN="{n}"

# What to say for named windows (use {name} for window name)
# Examples: "{name}", "Window {name}", "{name} ready"
NOTIFY_TMUX_NAME_PATTERN="{name}"
