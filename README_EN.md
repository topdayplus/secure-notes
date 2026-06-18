# Secure Notes

Secure Notes is a security-focused notes app with screenshot protection, background protection, and offline LAN migration without saving transferred data as a local file.

## Why This Project Exists

I recently switched between Android phones from different brands. Notes stored in the built-in notes app did not migrate cleanly through phone cloning, which was frustrating. I found some open-source encrypted notes apps that support encrypted export and import, but I wanted to see whether migration could avoid manual export entirely, and even work without internet access: two phones can form a local Wi-Fi or hotspot network and transfer data directly without leaving a migration file behind.

## Core Capabilities

- Offline LAN migration: no cloud service or internet access required.
- `.snote` file fallback: export an encrypted file when LAN transfer is unavailable.
- Privacy protection: blocks screenshots and recent-task preview leaks.
- Local data cleanup: clear all notes on the current phone from settings.

## How Offline Migration Works

1. Put both phones on the same local network.
   - They can connect to the same Wi-Fi.
   - Or one phone can create a hotspot and the other phone can join it.
   - The local network does not need internet access.
2. Start LAN sending on the old phone to generate a migration address and QR code.
3. Scan the QR code on the new phone to get the old phone's LAN migration address.
4. Compare the confirmation code and note count on both phones.
5. Allow sending on the old phone, then enter the migration passphrase on the new phone to import.

Notes are not uploaded to the cloud. The QR code contains only the LAN address, not note content.

## Use Cases

- Storing bank card PINs, account passwords, recovery phrases, or private reminders.
- Avoiding cloud sync, cloud drives, or third-party account systems for sensitive content.
- Moving notes to a new phone directly between two nearby devices.
- Migrating in restricted network environments where the phones can still share a local Wi-Fi or hotspot.

## Security And Privacy

- The app does not provide cloud sync.
- Notes are encrypted and stored on the device.
- Migration packages are encrypted with a migration passphrase.
- LAN migration transfers only encrypted migration packages.
- Camera permission is used only for scanning LAN migration QR codes.

## Tech Stack

- Flutter / Dart
- SQLite
- AES-GCM
- PBKDF2-HMAC-SHA256
- Android / iOS

## Project Status

The main Android flows are usable, including local encrypted notes, startup passcode, QR scanning, offline LAN migration, and `.snote` file migration.

The iOS project exists, but it still needs verification in a macOS/Xcode environment.

## Development

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Build an Android APK:

```powershell
flutter build apk --release
```

## Roadmap

- iOS device verification.
- App icon and launch screen.
- Dark mode.
- Note pinning, sorting, and categories.
- Android release signing and publishing preparation.
