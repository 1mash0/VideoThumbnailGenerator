# vtg — Video Thumbnail Generator CLI

A command-line tool for generating thumbnails from video files.  
Supports PNG and JPEG formats, with automatic file name adjustment to prevent overwriting.

## Requirements

- macOS 13 or later
- Swift 6
- Xcode Command Line Tools installed

## Installation

```bash
# Clone the repository
git clone https://github.com/1mash0/VideoThumbnailGenerator.git

cd VideoThumbnailGenerator

# Build & install (installs to /usr/local/bin by default)
make install

# Uninstall
make uninstall
```

> The provided `Makefile` installs the compiled binary as `vtg`.

## Usage

```bash
# `<input>` — Path to the input video file.
vtg [OPTIONS] <input>
```

## Arguments & Options

### Positional Arguments

- `input`:  
  Path to the input video file.

### Options

- `--timestamp <seconds>` / `-t <seconds>`:  
  Timestamp in seconds to extract. Defaults to the middle of the video if omitted.

- `--format <png | jpg>`:  
  Output image format override.  
  If the output path has a supported extension (`png`, `jpg`, `jpeg`), that extension determines the format.  
  If omitted, PNG format is used by default.

- `--output <path>` / `-o <path>`:  
  Path to the output image file (must include a supported extension).  
  If omitted, the output will be saved next to the input file.

## Examples

Generate a PNG thumbnail at the 5-second mark:

```bash
vtg /path/to/video.mp4 -t 5
```

Generate a JPEG thumbnail with an explicit output path:

```bash
vtg /path/to/video.mp4 --format jpg --output ~/Desktop/thumbnail.jpg
```

Output path extension overrides `--format`:

```bash
vtg /path/to/video.mov --format png --output ~/Desktop/out.jpg
```
