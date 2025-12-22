# Claude Code Notify

Notification sounds for Claude Code. Get audible alerts when Claude needs your attention.

## Features

- **Cross-platform**: Works on macOS, Linux, and Windows (Git Bash/WSL)
- **Smart defaults**: Platform-specific sounds out of the box (Hero on macOS, etc.)
- **Custom sounds**: Use any sound file on your system
- **Tmux speech** (opt-in): Speaks the window name/number so you know which session needs attention
- **Smart triggers**:
  - When Claude finishes and waits for input
  - When Claude requests permission (not auto-approved)

## Installation

```bash
claude marketplace add https://raw.githubusercontent.com/AbdelrahmanHafez/claude-code-notify/main/marketplace.json
claude plugin install notify@claude-code-notify
```

## Commands

| Command | Description |
|---------|-------------|
| `/notify:config` | Open config file in editor |
| `/notify:toggle-session` | Toggle notifications for current session only |
| `/notify:toggle-global` | Toggle notifications globally (persists) |
| `/notify:status` | Show current notification status |

## Configuration

Config is created automatically at `~/.claude/notify/config` on first session.

To edit, run:

```
/notify:config
```

### Options

```bash
# Enable/disable notifications globally
NOTIFY_ENABLED="true"

# Sound file (optional, platform-specific)
# Leave empty for platform default:
#   macOS: Hero.aiff | Linux: complete.oga | Windows: chimes.wav
#
# macOS options: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink
NOTIFY_SOUND=""

# Tmux speech (cross-platform, opt-in)
# Speaks window name/number after playing sound
# Requires: macOS (say), Linux (espeak or spd-say), Windows (PowerShell)
NOTIFY_TMUX_SPEECH="false"

# Voice for tmux speech
# macOS: `say -v '?'` | Linux: `espeak --voices` | Windows: see docs
NOTIFY_TMUX_VOICE="Samantha"

# Speech rate (words per minute)
NOTIFY_TMUX_SPEECH_RATE=200

# Pattern for numbered windows ({n} = window number)
NOTIFY_TMUX_WINDOW_PATTERN="Window {n}"

# Pattern for named windows ({name} = window name)
NOTIFY_TMUX_NAME_PATTERN="{name}"
```

### Examples

**Use Hero sound (macOS):**
```bash
NOTIFY_SOUND="/System/Library/Sounds/Hero.aiff"
```

**Enable tmux speech:**
```bash
NOTIFY_TMUX_SPEECH="true"
```

**Change voice:**
```bash
# macOS
NOTIFY_TMUX_VOICE="Daniel"
# Linux (espeak)
NOTIFY_TMUX_VOICE="en-gb"
```

**Just say the number:**
```bash
NOTIFY_TMUX_WINDOW_PATTERN="{n}"
```

**Add "ready" after window name:**
```bash
NOTIFY_TMUX_NAME_PATTERN="{name} ready"
```

## Tmux Speech Behavior

When `NOTIFY_TMUX_SPEECH="true"`:

| Window Name | What It Says |
|-------------|--------------|
| `fish`, `bash`, `zsh`, etc. | Uses `NOTIFY_TMUX_WINDOW_PATTERN` (e.g., "Window 3") |
| Custom name like `my-project` | Uses `NOTIFY_TMUX_NAME_PATTERN` (e.g., "my-project") |

## Platform Support

| Platform | Sound | Tmux Speech |
|----------|-------|-------------|
| macOS | `afplay` or terminal bell | `say` |
| Linux | `paplay`, `aplay`, or terminal bell | `espeak` or `spd-say` |
| Windows | `powershell.exe` or terminal bell | PowerShell `SpeechSynthesizer` |

## License

MIT
