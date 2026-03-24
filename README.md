# AWAVE

AWAVE is a macOS menu bar application for privacy-friendly audio-to-text transcription. Hold a global hotkey to record, see a real-time waveform overlay, and have the transcription automatically pasted into your current app. Transcription is performed via an [OpenAI Audio Transcription API](https://platform.openai.com/docs/api-reference/audio/createTranscription) compatible API by default. If you want to transcribe audio locally, you can use a self-hosted [Speaches](https://github.com/speaches-ai/speaches/) server.

## Features

- **Global Hotkey:** Press and hold (default: `Cmd+Shift+A`) to record audio from anywhere
- **Real-time Waveform:** Animated overlay visualizes your voice input
- **Auto-paste:** Transcription is instantly pasted into the focused application
- **Menu Bar App:** Lightweight, runs quietly in the menu bar

## Requirements

- macOS 14.0+
- Swift 6.0+
- Microphone access

## Permissions

On first run, AWAVE will request:
- **Microphone access:** Required for audio recording
- **Accessibility & Input Monitoring:** Required for hotkey and auto-paste features

If permissions are denied, you can enable them in System Settings > Privacy & Security.

## Installation & Setup

Clone the repository and install application to `/Applications`.

```bash
$ gh repo clone x-color/awave
$ cd awave
$ just install
```

## Usage

1. (Optional) For local transcription: If you want to run transcription locally, start the Speaches server before running AWAVE.
2. Launch AWAVE (it appears in the menu bar with a waveform icon)
3. Press and hold the global hotkey (default: Cmd+Shift+A) to start recording
4. Overlay waveform appears at the bottom of the screen
5. Release the hotkey to stop recording
6. Transcription is pasted into your current app automatically

## Configuration

Configure the following settings in the menu bar app:
- Hotkey: Default is `Cmd+Shift+A`.
- Transcription API endpoint
- Transcription Model name
- (Optional) OpenAI API key
