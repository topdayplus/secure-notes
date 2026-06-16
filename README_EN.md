# Secure Notes

Secure Notes is a local-first encrypted notes app focused on one problem: sensitive notes are encrypted and stored only on the phone. When moving to a new phone, data can be migrated over a local network while both phones are offline from the internet, without saving the fetched migration package as a file, or exported as an encrypted file for manual transfer.

## Core Capabilities

- Local encrypted storage: note content is encrypted before being written to the local database.
- Startup passcode and auto-lock: protects app entry and background return.
- Offline LAN migration: works without cloud services or internet access.
- QR pairing: the old phone shows a migration QR code, and the new phone scans it to get the LAN address.
- Migration confirmation: both phones compare the confirmation code and note count before transfer.
- Encrypted migration package: LAN transfer sends encrypted data, not plaintext notes.
- `.snote` file fallback: export an encrypted file when LAN transfer is unavailable.
- Import progress: large imports show decryption and write progress.
- Android privacy protection: blocks screenshots and recent-task preview leaks.

## How Offline Migration Works

1. Put both phones on the same local network.
   - They can connect to the same Wi-Fi.
   - Or one phone can create a hotspot and the other phone can join it.
   - The local network does not need internet access.
2. Start LAN sending on the old phone to generate a migration address and QR code.
3. Scan the QR code on the new phone to fetch the old phone's LAN migration address.
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

See [PRIVACY_EN.md](PRIVACY_EN.md) for the short privacy statement.

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
