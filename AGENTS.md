# AWAVE Development Guide

## Project Overview

AWAVE is a macOS menu bar application that records audio via a global hotkey and transcribes it using Audio Transcription API. It features real-time waveform visualization and auto-paste functionality.

## Technology Stack

- Language: Swift 6.0+
- Platform: macOS 14.0+
- Package Manager: Swift Package Manager
- UI Framework: SwiftUI

### Dependencies

- Speaches: A local server for Audio Transcription API. It should start before running the app.

This is a sample request to the local Speaches server for transcription:

```bash
curl -s "localhost:8000/v1/audio/transcriptions" -F "file=@audio.wav" -F "model=Systran/faster-whisper-small"
```

## Build Commands

```bash
# Build the project
just build

# Build for release
just build -c release

# Run the app
just run

# Format the code
just format

# Lint the code
just lint
```

## Development Rules

You must follow these rules during development:
- Follow Swift best practices and style guidelines
- Run formatting and linting after code changes every time
- Run tests before reporting the task complete to the user