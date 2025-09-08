
# Yoonu Njub App Analysis

This document outlines the functionality of the Yoonu Njub Flutter application.

## Core Functionality

The app is an audio player for a series of shows called "Yoonu Njub". Here's a breakdown of its main features:

*   **Audio Playback:** The app plays a series of audio shows. The list of shows is loaded from a local `shows.json` file.
*   **Streaming and Downloading:** Audio files can be streamed from a remote server. The app also supports downloading files for offline playback.
*   **State Management:** The app uses the `provider` package for state management, with the following providers:
    *   `Shows`: Manages the list of shows, fetches data, and handles downloads.
    *   `PlayerManager`: Controls the audio player using the `just_audio` package.
    *   `ThemeModel`: Manages the app's theme and language settings.
*   **Localization:** The app supports English and French, with a workaround to support Wolof using the Swiss French locale (`fr_CH`).
*   **Persistence:** The app uses `shared_preferences` to remember the last played show and user preferences for theme and language.
*   **Background Audio:** The `just_audio_background` package is used to enable background audio playback and control from the device's notification area.
*   **User Interface:** The UI consists of a main player screen, a settings screen, and an about screen.
*   **Error Reporting:** There is a developer-facing feature to check for broken audio links on the server. If broken links are found, an email report is sent.

## Technical Details

*   **Platform:** Flutter
*   **Dependencies:**
    *   `provider` (state management)
    *   `just_audio` (audio playback)
    *   `just_audio_background` (background audio)
    *   `http` (networking)
    *   `shared_preferences` (local storage)
    *   `flutter_localizations`, `intl` (localization)
    *   `firebase_core`, `firebase_analytics` (analytics)
