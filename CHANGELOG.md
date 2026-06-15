# Changelog
## Unreleased

### Fixed
- Prevented the reminder from appearing after a run started by the player.
- Made the keystone start button hook more reliable when the keystone receptacle opens.

## 1.0.8 - 2026-06-14

### Added
- Added a dedicated locale module for addon text.
- Added a dedicated keystone module for Mythic+ key lookup, formatting, and reminder decision logic.
- Added a small debug helper that can be enabled from the addon table during development.

### Changed
- Split responsibilities between initialization, locale, keystone logic, events, and UI files.
- Simplified the event handler by moving keystone state handling into reusable addon methods.
- Simplified the reminder UI so it only builds and updates the popup.
- Updated the addon version to 1.0.8.
- Cleaned the README folder structure example.

### Fixed
- Fixed the package name metadata to match the addon folder name.

## 1.0.7

- Fix interface version

## 1.0.6

- initial release
- Added Mythic+ key reminder
- Added reminder popup
