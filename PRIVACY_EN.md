# Privacy Statement

Secure Notes is a local-first encrypted notes app. It does not provide cloud sync, account login, analytics, ads, or remote backup.

## Data Stored On Device

- Notes are stored locally in SQLite after encryption.
- The local encryption master key is stored in platform secure storage.
- The app passcode is stored only as verification material, not as plaintext.
- App settings such as language, startup passcode preference, and auto-lock delay are stored locally.

## Sensitive Permissions

### Camera

Used only for scanning LAN migration QR codes.

When moving notes to a new phone, the old phone can show a QR code containing the local migration address. The new phone can scan it to fill in the address automatically.

The app does not save photos, record videos, upload camera data, or use the camera for note content.

### Network Access

Used for offline LAN migration.

When both phones are on the same Wi-Fi or hotspot, the old phone starts a temporary local server, and the new phone downloads an encrypted migration package through the local network.

The migration package is encrypted. The app does not send notes to a cloud server.

### Local Secure Storage

Used for the local encryption master key, passcode verification material, language preference, startup passcode preference, and auto-lock setting.

The startup passcode is optional. If it is disabled, the app opens directly to the notes home screen, while note fields remain encrypted at rest in local storage.

### Local Database Storage

Used for encrypted notes. Note title and body are encrypted before being written to SQLite.

### Migration Files

Used only when the user chooses advanced file migration.

The old phone can export an encrypted `.snote` file through the system save dialog. The new phone can import that `.snote` file through the system file picker and the migration passphrase.

The file is compressed before encryption and does not contain plaintext notes. After import, the app asks whether to delete the migration file when the selected file path can be deleted by the app.

## What The App Does Not Do

- Does not upload notes.
- Does not sync notes through the internet.
- Does not collect analytics.
- Does not show ads.
- Does not store plaintext notes in the database.
- Does not use the camera unless the user opens the QR scan function.
