# XiexiePet

XiexiePet is a tiny native macOS desktop pet that quietly stays with you and says
"谢谢". It floats above the desktop, lives in the menu bar, can be resized, and
tries to stay low-interruption.

## Features

- Native SwiftUI macOS pet window
- Menu bar extra for showing, hiding, feeding, waking, sleeping, and quitting
- Right-click pet actions: feed food, feed water, feed medicine, wake, sleep
- Small transparent floating window with drag support
- Hover cursor changes to a hand, so the pet feels tappable and pat-able
- Automatic blink, breathing, nap, escape, and return behaviors
- Day/night behavior that adapts to system time
- Rest logic that considers CPU load, battery state, low power mode, and thermal state
- No network calls and no external services

## Requirements

- macOS 14 or newer
- Xcode Command Line Tools or Xcode
- Swift 5.9+

Install the command line tools if needed:

```sh
xcode-select --install
```

## Run

Clone the project and run:

```sh
git clone https://github.com/YOUR_NAME/XiexiePet.git
cd XiexiePet
./script/build_and_run.sh
```

The script builds the Swift package, creates `dist/XiexiePetMac.app`, and opens
the app.

For a quick build-only check:

```sh
swift build
```

For build and launch verification:

```sh
./script/build_and_run.sh --verify
```

## Use

- Drag the pet from anywhere in the pet window.
- Click or pat the pet to make it respond.
- Right-click the pet for quick actions.
- Use the menu bar "谢谢宠物" item to show or hide the pet.
- Resize the window from the edge if you want a smaller or larger companion.

## Privacy And Security

XiexiePet is intentionally local-first:

- It does not make network requests.
- It does not collect analytics.
- It does not read personal files.
- It only reads system resource signals needed for behavior, such as CPU load,
  power source state, low power mode, and thermal state.

## Development

Project layout:

```text
Sources/XiexiePetMac/App       App entry point and app delegate
Sources/XiexiePetMac/Models    Small value models
Sources/XiexiePetMac/Services  CPU and battery monitor
Sources/XiexiePetMac/Stores    Pet state and behavior
Sources/XiexiePetMac/Views     SwiftUI/AppKit views and interaction layers
script/build_and_run.sh        Local build and app bundle helper
```

Run checks before opening a pull request:

```sh
swift build
./script/build_and_run.sh --verify
```

## License

XiexiePet is released under a non-commercial source-available license.

You may use, copy, modify, and share it freely for non-commercial purposes.
Commercial use is not allowed without prior written permission.
