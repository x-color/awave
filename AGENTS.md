# AGENTS.md - AWAVE Development Guide

This file provides guidance for agentic coding agents working on the AWAVE project.

## Project Overview

AWAVE is a macOS menu bar application that records audio via a global hotkey and transcribes it using Audio Transcription API. It features real-time waveform visualization and auto-paste functionality.

## Technology Stack

- Language: Swift 6.0+
- Platform: macOS 14.0+
- Package Manager: Swift Package Manager
- UI Framework: SwiftUI
- Key Dependencies: [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)

### Dependencies

- Speaches: A local server for Audio Transcription API. It should start before running the app.

This is a sample request to the local Speaches server for transcription:

```bash
curl -s "localhost:8000/v1/audio/transcriptions" -F "file=@audio.wav" -F "model=Systran/faster-whisper-small"
```

## Build Commands

```bash
# Build the project
swift build

# Run the app
swift run

# Build for release
swift build -c release
```
