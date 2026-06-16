# Changelog
## 1.1.1 - 2026-06-16

### Fixed
- Updated the TOC interface version for WoW 12.0.7.

## 1.1.0 - 2026-06-15

### Added
- Added reminder popup position persistence between sessions.
- Added Shift-click on the OK button to reset the reminder popup position without closing it.
- Added a tooltip to explain the OK button and Shift-click position reset.
- Added Escape support to close the reminder popup.
- Added soft open and close sounds for the reminder popup.

### Changed
- Refreshed the reminder popup layout with an icon, left-aligned content, and a compact native frame.
- Made the reminder popup movable.

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
