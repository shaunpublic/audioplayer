# audioplayer

## Table of contents

- [Technologies](#technologies)
- [Setup](#setup)
- [Architecture](#architecture)

## Technologies

`audioplayer` is created with:

- Xcode version: 13.2.1
- Swift version: 5

## Setup

To run this project, just open the Xcode project, build, and run!
(If looking to build to a device, of course, you'll have to assign a development team.)

## Architecture

- The main application class can be found in `AudioPlayerApp.swift`, and contains a `sampleUrl` constant for supplying the URL to a test track
- Some extensions were written to decorate existing Foundation and AVKit functionality; mainly used for convenience methods during development
- The `ControlCenterHelper` class was written as a Singleton, as it makes sense to highlight and enforce the singular nature of the Now Playing and Remote Control OS features

#### Suggested Architectural Improvements

- Move AVPlayer out to a ViewModel for the PlayerView, or treat as part of the application model, as the AVPlayer feels like it should be considered to be app-wide on this occasion.
- Expose `currentTime`, `duration`, and `isPlaying` from the AVPlayer's new location, and treat them as Bindings within the PlayerView
- Consolidate observers used by each of the main view and the `ControlCenterHelper`, to avoid managing multiple periodic time observers that are essentially doing the same job.
- Implement `PreviewProviders` for the main player View and custom subviews within the project, for author-time previews

#### Suggested Next Features

- Retrieve metadata for the m3u8 file, to display correct media title and artist
- Audio interruption handling
