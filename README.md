# AWAVE

AWAVE is a macOS menu bar application for privacy-friendly audio-to-text transcription. Hold a global hotkey to record, see a real-time waveform overlay, and have the transcription automatically pasted into your current app. Transcription is performed locally via a self-hosted [Speaches](https://github.com/speaches-ai/speaches/) server.

## Features

- **Global Hotkey:** Press and hold (default: `Cmd+Shift+A`) to record audio from anywhere
- **Real-time Waveform:** Animated overlay visualizes your voice input
- **Auto-paste:** Transcription is instantly pasted into the focused application
- **Menu Bar App:** Lightweight, runs quietly in the menu bar

## Requirements

- macOS 14.0+
- Swift 6.0+
- Microphone access
- [Speaches](https://github.com/speaches-ai/speaches) local transcription server

## Permissions

On first run, AWAVE will request:
- **Microphone access:** Required for audio recording
- **Accessibility & Input Monitoring:** Required for hotkey and auto-paste features

If permissions are denied, you can enable them in System Settings > Privacy & Security.

## Installation & Setup

1. **Clone this repository**
2. **Start the Speaches server** before running AWAVE:
   ```bash
   $ curl --silent --remote-name https://raw.githubusercontent.com/speaches-ai/speaches/master/compose.yaml
   $ curl --silent --remote-name https://raw.githubusercontent.com/speaches-ai/speaches/master/compose.cpu.yaml
   $ docker compose -f compose.cpu.yaml up

   $ ./scripts/register.sh
   ```
3. **Build and run AWAVE:**
   ```bash
   $ swift build
   $ swift run
   ```

## Usage

1. Launch AWAVE (it appears in the menu bar with a waveform icon)
2. Press and hold the global hotkey (default: Cmd+Shift+A) to start recording
3. Overlay waveform appears at the bottom of the screen
4. Release the hotkey to stop recording
5. Transcription is pasted into your current app automatically

## Configuration

- **Hotkey:** Change the global hotkey from the menu bar popover
- **Transcription server:** By default, AWAVE connects to `http://localhost:8000` and uses the `Systran/faster-whisper-small` model. You can modify this in the code if needed.

## Development

- Build: `swift build`
- Run: `swift run`
- Release build: `swift build -c release`