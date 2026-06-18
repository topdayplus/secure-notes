import 'app_language.dart';

class AppStrings {
  const AppStrings._(this.appLanguage);

  final AppLanguage appLanguage;

  static AppStrings of(AppLanguage language) => AppStrings._(language);

  String get appTitle => switch (appLanguage) {
    AppLanguage.zhHans => '安全便签',
    AppLanguage.zhHant => '安全便签',
    AppLanguage.en => '安全便签',
  };

  String get homeTitle => switch (appLanguage) {
    AppLanguage.zhHans => '便签',
    AppLanguage.zhHant => '便簽',
    AppLanguage.en => 'Notes',
  };

  String get createPasscode => switch (appLanguage) {
    AppLanguage.zhHans => '创建应用口令',
    AppLanguage.zhHant => '建立應用程式口令',
    AppLanguage.en => 'Create app passcode',
  };

  String get unlockNotes => switch (appLanguage) {
    AppLanguage.zhHans => '解锁便签',
    AppLanguage.zhHant => '解鎖便條',
    AppLanguage.en => 'Unlock notes',
  };

  String get passcode => switch (appLanguage) {
    AppLanguage.zhHans => '口令',
    AppLanguage.zhHant => '口令',
    AppLanguage.en => 'Passcode',
  };

  String get confirmPasscode => switch (appLanguage) {
    AppLanguage.zhHans => '确认口令',
    AppLanguage.zhHant => '確認口令',
    AppLanguage.en => 'Confirm passcode',
  };

  String get currentPasscode => switch (appLanguage) {
    AppLanguage.zhHans => '当前口令',
    AppLanguage.zhHant => '目前口令',
    AppLanguage.en => 'Current passcode',
  };

  String get newPasscode => switch (appLanguage) {
    AppLanguage.zhHans => '新口令',
    AppLanguage.zhHant => '新口令',
    AppLanguage.en => 'New passcode',
  };

  String get savePasscode => switch (appLanguage) {
    AppLanguage.zhHans => '保存口令',
    AppLanguage.zhHant => '儲存口令',
    AppLanguage.en => 'Save passcode',
  };

  String get changePasscode => switch (appLanguage) {
    AppLanguage.zhHans => '修改应用口令',
    AppLanguage.zhHant => '修改應用程式口令',
    AppLanguage.en => 'Change app passcode',
  };

  String get changePasscodeDescription => switch (appLanguage) {
    AppLanguage.zhHans => '修改解锁口令不会导出数据，也不会改变本地加密主密钥。',
    AppLanguage.zhHant => '修改解鎖口令不會匯出資料，也不會改變本機加密主金鑰。',
    AppLanguage.en =>
      'Changing the unlock passcode does not export data or change the local encryption key.',
  };

  String get unlock => switch (appLanguage) {
    AppLanguage.zhHans => '解锁',
    AppLanguage.zhHant => '解鎖',
    AppLanguage.en => 'Unlock',
  };

  String get passcodeTooShort => switch (appLanguage) {
    AppLanguage.zhHans => '请至少输入 6 位数字或字符。',
    AppLanguage.zhHant => '請至少輸入 6 位數字或字元。',
    AppLanguage.en => 'Use at least 6 digits or characters.',
  };

  String get passcodeMismatch => switch (appLanguage) {
    AppLanguage.zhHans => '两次输入的口令不一致。',
    AppLanguage.zhHant => '兩次輸入的口令不一致。',
    AppLanguage.en => 'Passcodes do not match.',
  };

  String get passcodeChanged => switch (appLanguage) {
    AppLanguage.zhHans => '应用口令已修改。',
    AppLanguage.zhHant => '應用程式口令已修改。',
    AppLanguage.en => 'App passcode changed.',
  };

  String get wrongPasscode => switch (appLanguage) {
    AppLanguage.zhHans => '口令错误。',
    AppLanguage.zhHant => '口令錯誤。',
    AppLanguage.en => 'Wrong passcode.',
  };

  String unlockLocked(int seconds) => switch (appLanguage) {
    AppLanguage.zhHans => '错误次数过多，请 $seconds 秒后再试。',
    AppLanguage.zhHant => '錯誤次數過多，請 $seconds 秒後再試。',
    AppLanguage.en =>
      'Too many failed attempts. Try again in $seconds seconds.',
  };

  String get languageLabel => switch (appLanguage) {
    AppLanguage.zhHans => '语言',
    AppLanguage.zhHant => '語言',
    AppLanguage.en => 'Language',
  };

  String get securityCheck => switch (appLanguage) {
    AppLanguage.zhHans => '安全检查',
    AppLanguage.zhHant => '安全檢查',
    AppLanguage.en => 'Security check',
  };

  String get offlineMigration => switch (appLanguage) {
    AppLanguage.zhHans => '离线迁移',
    AppLanguage.zhHant => '離線遷移',
    AppLanguage.en => 'Offline migration',
  };

  String get lockNow => switch (appLanguage) {
    AppLanguage.zhHans => '立即锁定',
    AppLanguage.zhHant => '立即鎖定',
    AppLanguage.en => 'Lock now',
  };

  String get settings => switch (appLanguage) {
    AppLanguage.zhHans => '设置',
    AppLanguage.zhHant => '設定',
    AppLanguage.en => 'Settings',
  };

  String get confirm => switch (appLanguage) {
    AppLanguage.zhHans => '确认',
    AppLanguage.zhHant => '確認',
    AppLanguage.en => 'Confirm',
  };

  String get createStartupPasscodeQuestion => switch (appLanguage) {
    AppLanguage.zhHans => '是否创建启动密码？',
    AppLanguage.zhHant => '是否建立啟動密碼？',
    AppLanguage.en => 'Create a startup passcode?',
  };

  String get createStartupPasscodeDescription => switch (appLanguage) {
    AppLanguage.zhHans => '用于打开应用时保护便签，可稍后在设置中开启。',
    AppLanguage.zhHant => '用於開啟應用時保護便箋，可稍後在設定中開啟。',
    AppLanguage.en =>
      'Protect notes when opening the app. You can enable it later in settings.',
  };

  String get skipForNow => switch (appLanguage) {
    AppLanguage.zhHans => '暂不创建',
    AppLanguage.zhHant => '暫不建立',
    AppLanguage.en => 'Skip for now',
  };

  String get startupPasscodeSkipped => switch (appLanguage) {
    AppLanguage.zhHans => '已跳过启动密码，可稍后在设置中开启。',
    AppLanguage.zhHant => '已略過啟動密碼，可稍後在設定中開啟。',
    AppLanguage.en =>
      'Startup passcode skipped. You can enable it later in settings.',
  };

  String get startupPasscode => switch (appLanguage) {
    AppLanguage.zhHans => '启动密码',
    AppLanguage.zhHant => '啟動密碼',
    AppLanguage.en => 'Startup passcode',
  };

  String get startupPasscodeDescription => switch (appLanguage) {
    AppLanguage.zhHans => '开启后，打开应用或触发锁定后需要输入密码。',
    AppLanguage.zhHant => '開啟後，開啟應用程式或觸發鎖定後需要輸入密碼。',
    AppLanguage.en =>
      'When enabled, opening the app or triggering lock requires the passcode.',
  };

  String get disableStartupPasscode => switch (appLanguage) {
    AppLanguage.zhHans => '关闭启动密码',
    AppLanguage.zhHant => '關閉啟動密碼',
    AppLanguage.en => 'Disable startup passcode',
  };

  String get disableStartupPasscodeDescription => switch (appLanguage) {
    AppLanguage.zhHans => '请输入当前密码确认关闭。关闭后，打开应用将直接进入便签主页。',
    AppLanguage.zhHant => '請輸入目前密碼確認關閉。關閉後，開啟應用程式將直接進入便箋首頁。',
    AppLanguage.en =>
      'Enter the current passcode to confirm. After disabling it, the app opens directly to the notes home screen.',
  };

  String get dangerZone => switch (appLanguage) {
    AppLanguage.zhHans => '危险操作',
    AppLanguage.zhHant => '危險操作',
    AppLanguage.en => 'Danger zone',
  };

  String get clearAllNotes => switch (appLanguage) {
    AppLanguage.zhHans => '清空所有便签',
    AppLanguage.zhHant => '清空所有便條',
    AppLanguage.en => 'Clear all notes',
  };

  String get clearAllNotesDescription => switch (appLanguage) {
    AppLanguage.zhHans => '删除当前手机上的所有便签，不删除启动密码、设置或已导出的迁移文件。',
    AppLanguage.zhHant => '刪除目前手機上的所有便條，不刪除啟動密碼、設定或已匯出的遷移檔案。',
    AppLanguage.en =>
      'Delete all notes on this device. Startup passcode, settings, and exported migration files are not removed.',
  };

  String get clearAllNotesConfirmTitle => switch (appLanguage) {
    AppLanguage.zhHans => '清空所有便签？',
    AppLanguage.zhHant => '清空所有便條？',
    AppLanguage.en => 'Clear all notes?',
  };

  String get clearAllNotesConfirmBody => switch (appLanguage) {
    AppLanguage.zhHans => '此操作会删除当前手机上的所有便签，且不可恢复。已导出的 .snote 文件不会被删除。',
    AppLanguage.zhHant => '此操作會刪除目前手機上的所有便條，且無法復原。已匯出的 .snote 檔案不會被刪除。',
    AppLanguage.en =>
      'This will delete all notes on this device and cannot be undone. Exported .snote files are not removed.',
  };

  String get clearAllNotesPasscodeTitle => switch (appLanguage) {
    AppLanguage.zhHans => '确认启动密码',
    AppLanguage.zhHant => '確認啟動密碼',
    AppLanguage.en => 'Confirm startup passcode',
  };

  String get clearAllNotesPasscodeDescription => switch (appLanguage) {
    AppLanguage.zhHans => '请输入当前启动密码后再清空所有便签。',
    AppLanguage.zhHant => '請輸入目前啟動密碼後再清空所有便條。',
    AppLanguage.en =>
      'Enter the current startup passcode before clearing all notes.',
  };

  String get allNotesCleared => switch (appLanguage) {
    AppLanguage.zhHans => '已清空所有便签。',
    AppLanguage.zhHant => '已清空所有便條。',
    AppLanguage.en => 'All notes cleared.',
  };

  String get moreActions => switch (appLanguage) {
    AppLanguage.zhHans => '更多操作',
    AppLanguage.zhHant => '更多操作',
    AppLanguage.en => 'More actions',
  };

  String get autoLockDelay => switch (appLanguage) {
    AppLanguage.zhHans => '后台后重新解锁',
    AppLanguage.zhHant => '切到背景後重新解鎖',
    AppLanguage.en => 'Require unlock after background',
  };

  String get autoLockDelayDescription => switch (appLanguage) {
    AppLanguage.zhHans => '便签切到后台后，在设定时间内切回不需要重新输入口令。手动锁定不受影响。',
    AppLanguage.zhHant => '便條切到背景後，在設定時間內切回不需要重新輸入口令。手動鎖定不受影響。',
    AppLanguage.en =>
      'After the app goes to the background, returning within this delay will not require the passcode. Manual lock is not affected.',
  };

  String autoLockDelayOption(int seconds) => switch (appLanguage) {
    AppLanguage.zhHans => switch (seconds) {
      0 => '每次切回都需要解锁',
      15 => '15 秒内免解锁',
      30 => '30 秒内免解锁',
      60 => '1 分钟内免解锁',
      300 => '5 分钟内免解锁',
      900 => '15 分钟内免解锁',
      _ when seconds < 0 => '永不自动锁定',
      _ => '$seconds 秒内免解锁',
    },
    AppLanguage.zhHant => switch (seconds) {
      0 => '每次切回都需要解鎖',
      15 => '15 秒內免解鎖',
      30 => '30 秒內免解鎖',
      60 => '1 分鐘內免解鎖',
      300 => '5 分鐘內免解鎖',
      900 => '15 分鐘內免解鎖',
      _ when seconds < 0 => '永不自動鎖定',
      _ => '$seconds 秒內免解鎖',
    },
    AppLanguage.en => switch (seconds) {
      0 => 'Require unlock every time',
      15 => 'No unlock within 15 seconds',
      30 => 'No unlock within 30 seconds',
      60 => 'No unlock within 1 minute',
      300 => 'No unlock within 5 minutes',
      900 => 'No unlock within 15 minutes',
      _ when seconds < 0 => 'Never auto-lock',
      _ => 'No unlock within $seconds seconds',
    },
  };

  String get searchNotes => switch (appLanguage) {
    AppLanguage.zhHans => '搜索加密便签',
    AppLanguage.zhHant => '搜尋加密便條',
    AppLanguage.en => 'Search encrypted notes',
  };

  String get localEncryptedStorageHint => switch (appLanguage) {
    AppLanguage.zhHans => '本地加密存储',
    AppLanguage.zhHant => '本地加密儲存',
    AppLanguage.en => 'Local encrypted storage',
  };

  String get noNotesYet => switch (appLanguage) {
    AppLanguage.zhHans => '还没有便签',
    AppLanguage.zhHant => '尚無便條',
    AppLanguage.en => 'No notes yet',
  };

  String get noBody => switch (appLanguage) {
    AppLanguage.zhHans => '无正文',
    AppLanguage.zhHant => '無內文',
    AppLanguage.en => 'No body',
  };

  String get newNote => switch (appLanguage) {
    AppLanguage.zhHans => '新建便签',
    AppLanguage.zhHant => '新增便條',
    AppLanguage.en => 'New note',
  };

  String get editNote => switch (appLanguage) {
    AppLanguage.zhHans => '编辑便签',
    AppLanguage.zhHant => '編輯便條',
    AppLanguage.en => 'Edit note',
  };

  String get delete => switch (appLanguage) {
    AppLanguage.zhHans => '删除',
    AppLanguage.zhHant => '刪除',
    AppLanguage.en => 'Delete',
  };

  String get save => switch (appLanguage) {
    AppLanguage.zhHans => '保存',
    AppLanguage.zhHant => '儲存',
    AppLanguage.en => 'Save',
  };

  String get title => switch (appLanguage) {
    AppLanguage.zhHans => '标题',
    AppLanguage.zhHant => '標題',
    AppLanguage.en => 'Title',
  };

  String get optionalTitle => switch (appLanguage) {
    AppLanguage.zhHans => '标题（可选，留空会使用正文第一行）',
    AppLanguage.zhHant => '標題（可選，留空會使用內文第一行）',
    AppLanguage.en => 'Title (optional, uses the first body line if empty)',
  };

  String get privateNote => switch (appLanguage) {
    AppLanguage.zhHans => '私密便签',
    AppLanguage.zhHant => '私密便條',
    AppLanguage.en => 'Private note',
  };

  String get noteType => switch (appLanguage) {
    AppLanguage.zhHans => '类型',
    AppLanguage.zhHant => '類型',
    AppLanguage.en => 'Type',
  };

  String get plainNote => switch (appLanguage) {
    AppLanguage.zhHans => '普通便签',
    AppLanguage.zhHant => '普通便條',
    AppLanguage.en => 'Plain note',
  };

  String get credentialNote => switch (appLanguage) {
    AppLanguage.zhHans => '账号密码',
    AppLanguage.zhHant => '帳號密碼',
    AppLanguage.en => 'Account password',
  };

  String get account => switch (appLanguage) {
    AppLanguage.zhHans => '账号',
    AppLanguage.zhHant => '帳號',
    AppLanguage.en => 'Account',
  };

  String get password => switch (appLanguage) {
    AppLanguage.zhHans => '密码',
    AppLanguage.zhHant => '密碼',
    AppLanguage.en => 'Password',
  };

  String get website => switch (appLanguage) {
    AppLanguage.zhHans => '网址',
    AppLanguage.zhHant => '網址',
    AppLanguage.en => 'Website',
  };

  String get remark => switch (appLanguage) {
    AppLanguage.zhHans => '备注',
    AppLanguage.zhHant => '備註',
    AppLanguage.en => 'Remark',
  };

  String get copy => switch (appLanguage) {
    AppLanguage.zhHans => '复制',
    AppLanguage.zhHant => '複製',
    AppLanguage.en => 'Copy',
  };

  String copied(String label) => switch (appLanguage) {
    AppLanguage.zhHans => '已复制$label',
    AppLanguage.zhHant => '已複製$label',
    AppLanguage.en => '$label copied',
  };

  String copiedWithAutoClear(String label, int seconds) =>
      switch (appLanguage) {
        AppLanguage.zhHans => '已复制$label，剪贴板将在 $seconds 秒后清空。',
        AppLanguage.zhHant => '已複製$label，剪貼簿將在 $seconds 秒後清空。',
        AppLanguage.en =>
          '$label copied. Clipboard clears in $seconds seconds.',
      };

  String get deleteNoteQuestion => switch (appLanguage) {
    AppLanguage.zhHans => '删除便签？',
    AppLanguage.zhHant => '刪除便條？',
    AppLanguage.en => 'Delete note?',
  };

  String get deleteNoteBody => switch (appLanguage) {
    AppLanguage.zhHans => '这条便签会从本机移除。',
    AppLanguage.zhHant => '這則便條會從本機移除。',
    AppLanguage.en => 'This note will be removed from this device.',
  };

  String get cancel => switch (appLanguage) {
    AppLanguage.zhHans => '取消',
    AppLanguage.zhHant => '取消',
    AppLanguage.en => 'Cancel',
  };

  String get allow => switch (appLanguage) {
    AppLanguage.zhHans => '允许',
    AppLanguage.zhHant => '允許',
    AppLanguage.en => 'Allow',
  };

  String get deny => switch (appLanguage) {
    AppLanguage.zhHans => '拒绝',
    AppLanguage.zhHant => '拒絕',
    AppLanguage.en => 'Deny',
  };

  String get encryptedStoragePassed => switch (appLanguage) {
    AppLanguage.zhHans => '加密存储检查通过',
    AppLanguage.zhHant => '加密儲存檢查通過',
    AppLanguage.en => 'Encrypted storage check passed',
  };

  String get plaintextRiskFound => switch (appLanguage) {
    AppLanguage.zhHans => '发现明文存储风险',
    AppLanguage.zhHant => '發現明文儲存風險',
    AppLanguage.en => 'Plaintext storage risk found',
  };

  String auditSummary(int checkedNotes, int leakCount) => switch (appLanguage) {
    AppLanguage.zhHans => '已检查 $checkedNotes 条便签。明文匹配：$leakCount。',
    AppLanguage.zhHant => '已檢查 $checkedNotes 則便條。明文匹配：$leakCount。',
    AppLanguage.en =>
      'Checked $checkedNotes notes. Plaintext matches: $leakCount.',
  };

  String get localDatabase => switch (appLanguage) {
    AppLanguage.zhHans => '本地数据库',
    AppLanguage.zhHant => '本機資料庫',
    AppLanguage.en => 'Local database',
  };

  String get localDatabaseDescription => switch (appLanguage) {
    AppLanguage.zhHans => 'SQLite 只保存加密后的标题和正文。',
    AppLanguage.zhHant => 'SQLite 只儲存加密後的標題與內文。',
    AppLanguage.en => 'SQLite stores encrypted title and body fields.',
  };

  String get deviceKeyStorage => switch (appLanguage) {
    AppLanguage.zhHans => '设备密钥存储',
    AppLanguage.zhHant => '裝置金鑰儲存',
    AppLanguage.en => 'Device key storage',
  };

  String get deviceKeyStorageDescription => switch (appLanguage) {
    AppLanguage.zhHans => '主密钥材料保存在平台安全存储中。',
    AppLanguage.zhHant => '主金鑰材料保存在平台安全儲存中。',
    AppLanguage.en => 'Master key material is kept in platform secure storage.',
  };

  String get migrationStep1Title => switch (appLanguage) {
    AppLanguage.zhHans => '1. 建立本地网络',
    AppLanguage.zhHant => '1. 建立本機網路',
    AppLanguage.en => '1. Create a local network',
  };

  String get migrationStep1Body => switch (appLanguage) {
    AppLanguage.zhHans => '使用同一个 Wi-Fi；无互联网时，可开启手机热点。',
    AppLanguage.zhHant => '使用同一個 Wi-Fi；無網際網路時，可開啟手機熱點。',
    AppLanguage.en =>
      'Use the same Wi-Fi, or open a phone hotspot when internet is unavailable.',
  };

  String get migrationStep2Title => switch (appLanguage) {
    AppLanguage.zhHans => '2. 通过二维码配对',
    AppLanguage.zhHant => '2. 透過 QR Code 配對',
    AppLanguage.en => '2. Pair with QR code',
  };

  String get migrationStep2Body => switch (appLanguage) {
    AppLanguage.zhHans => '二维码只包含短时会话描述，不包含便签内容。',
    AppLanguage.zhHant => 'QR Code 只包含短效會話描述，不包含便條內容。',
    AppLanguage.en =>
      'The QR code will contain only a short-lived session descriptor, never note content.',
  };

  String get migrationStep3Title => switch (appLanguage) {
    AppLanguage.zhHans => '3. 双端确认',
    AppLanguage.zhHant => '3. 雙端確認',
    AppLanguage.en => '3. Confirm both devices',
  };

  String get migrationStep3Body => switch (appLanguage) {
    AppLanguage.zhHans => '两台手机显示相同确认码后，旧手机才会发送数据。',
    AppLanguage.zhHant => '兩台手機顯示相同確認碼後，舊手機才會傳送資料。',
    AppLanguage.en =>
      'Both phones must show the same confirmation code before data leaves the old phone.',
  };

  String get migrationStep4Title => switch (appLanguage) {
    AppLanguage.zhHans => '4. 传输加密数据',
    AppLanguage.zhHant => '4. 傳輸加密資料',
    AppLanguage.en => '4. Transfer encrypted data',
  };

  String get migrationStep4Body => switch (appLanguage) {
    AppLanguage.zhHans => '便签会使用一次性本地会话加密传输，并在新手机上重新加密。',
    AppLanguage.zhHant => '便條會使用一次性本機會話加密傳輸，並在新手機上重新加密。',
    AppLanguage.en =>
      'Notes are encrypted for a one-time local session and re-encrypted on the new phone.',
  };

  String get migrationPackageIntro => switch (appLanguage) {
    AppLanguage.zhHans =>
      '第一版离线迁移使用加密文本包：旧手机生成后复制到新手机，新手机用同一个迁移口令导入。迁移包不会包含明文便签。',
    AppLanguage.zhHant =>
      '第一版離線遷移使用加密文字包：舊手機產生後複製到新手機，新手機用同一個遷移口令匯入。遷移包不會包含明文便條。',
    AppLanguage.en =>
      'This first offline migration version uses an encrypted text package. Generate it on the old phone, copy it to the new phone, then import it with the same migration passphrase. The package does not contain plaintext notes.',
  };

  String get exportMigrationPackage => switch (appLanguage) {
    AppLanguage.zhHans => '导出迁移包',
    AppLanguage.zhHant => '匯出遷移包',
    AppLanguage.en => 'Export migration package',
  };

  String get importMigrationPackage => switch (appLanguage) {
    AppLanguage.zhHans => '导入迁移包',
    AppLanguage.zhHant => '匯入遷移包',
    AppLanguage.en => 'Import migration package',
  };

  String get advancedMigration => switch (appLanguage) {
    AppLanguage.zhHans => '高级迁移方式',
    AppLanguage.zhHant => '進階遷移方式',
    AppLanguage.en => 'Advanced migration',
  };

  String get advancedMigrationDescription => switch (appLanguage) {
    AppLanguage.zhHans => '仅在局域网不可用或大批量迁移失败时使用。',
    AppLanguage.zhHant => '僅在區域網路不可用或大量遷移失敗時使用。',
    AppLanguage.en =>
      'Use only when LAN migration is unavailable or large migration fails.',
  };

  String get exportMigrationFile => switch (appLanguage) {
    AppLanguage.zhHans => '导出加密迁移文件',
    AppLanguage.zhHant => '匯出加密遷移檔案',
    AppLanguage.en => 'Export encrypted migration file',
  };

  String get importMigrationFile => switch (appLanguage) {
    AppLanguage.zhHans => '导入加密迁移文件',
    AppLanguage.zhHant => '匯入加密遷移檔案',
    AppLanguage.en => 'Import encrypted migration file',
  };

  String get importFromImportDirectory => switch (appLanguage) {
    AppLanguage.zhHans => '从导入目录读取',
    AppLanguage.zhHant => '從匯入目錄讀取',
    AppLanguage.en => 'Read from import folder',
  };

  String get migrationFilePath => switch (appLanguage) {
    AppLanguage.zhHans => '迁移文件位置',
    AppLanguage.zhHant => '遷移檔案位置',
    AppLanguage.en => 'Migration file path',
  };

  String get importDirectoryPath => switch (appLanguage) {
    AppLanguage.zhHans => '导入目录位置',
    AppLanguage.zhHant => '匯入目錄位置',
    AppLanguage.en => 'Import folder path',
  };

  String migrationFileExported(int count) => switch (appLanguage) {
    AppLanguage.zhHans => '已导出 $count 条便签的加密迁移文件。',
    AppLanguage.zhHant => '已匯出 $count 則便箋的加密遷移檔案。',
    AppLanguage.en => 'Exported an encrypted migration file with $count notes.',
  };

  String get deleteMigrationFileTitle => switch (appLanguage) {
    AppLanguage.zhHans => '删除迁移文件？',
    AppLanguage.zhHant => '刪除遷移檔案？',
    AppLanguage.en => 'Delete migration file?',
  };

  String get deleteMigrationFileBody => switch (appLanguage) {
    AppLanguage.zhHans => '导入已完成。是否删除刚刚导入的迁移文件？',
    AppLanguage.zhHant => '匯入已完成。是否刪除剛剛匯入的遷移檔案？',
    AppLanguage.en =>
      'Import is complete. Delete the migration file that was just imported?',
  };

  String get migrationFileDeleted => switch (appLanguage) {
    AppLanguage.zhHans => '迁移文件已删除。',
    AppLanguage.zhHant => '遷移檔案已刪除。',
    AppLanguage.en => 'Migration file deleted.',
  };

  String get noMigrationFileInImportDirectory => switch (appLanguage) {
    AppLanguage.zhHans => '导入目录中没有 .snote 文件。',
    AppLanguage.zhHant => '匯入目錄中沒有 .snote 檔案。',
    AppLanguage.en => 'No .snote file was found in the import folder.',
  };

  String get filePickerUnavailableUseImportDirectory => switch (appLanguage) {
    AppLanguage.zhHans => '当前系统文件选择器不可用，请使用导入目录读取。',
    AppLanguage.zhHant => '目前系統檔案選擇器不可用，請使用匯入目錄讀取。',
    AppLanguage.en =>
      'The system file picker is unavailable. Use the import folder instead.',
  };

  String get migrationPassphrase => switch (appLanguage) {
    AppLanguage.zhHans => '迁移口令',
    AppLanguage.zhHant => '遷移口令',
    AppLanguage.en => 'Migration passphrase',
  };

  String get migrationPassphraseHint => switch (appLanguage) {
    AppLanguage.zhHans => '至少 8 位，只告诉新手机使用者，不要和迁移包放在一起。',
    AppLanguage.zhHant => '至少 8 位，只告訴新手機使用者，不要和遷移包放在一起。',
    AppLanguage.en =>
      'At least 8 characters. Share it separately from the migration package.',
  };

  String get samePassphraseHint => switch (appLanguage) {
    AppLanguage.zhHans => '输入旧手机生成迁移包时使用的同一个口令。',
    AppLanguage.zhHant => '輸入舊手機產生遷移包時使用的同一個口令。',
    AppLanguage.en => 'Use the same passphrase that was used on the old phone.',
  };

  String get generatePackage => switch (appLanguage) {
    AppLanguage.zhHans => '生成迁移包',
    AppLanguage.zhHant => '產生遷移包',
    AppLanguage.en => 'Generate package',
  };

  String get encryptedMigrationPackage => switch (appLanguage) {
    AppLanguage.zhHans => '加密迁移包',
    AppLanguage.zhHant => '加密遷移包',
    AppLanguage.en => 'Encrypted migration package',
  };

  String get copyPackage => switch (appLanguage) {
    AppLanguage.zhHans => '复制迁移包',
    AppLanguage.zhHant => '複製遷移包',
    AppLanguage.en => 'Copy package',
  };

  String get pasteMigrationPackage => switch (appLanguage) {
    AppLanguage.zhHans => '粘贴迁移包',
    AppLanguage.zhHant => '貼上遷移包',
    AppLanguage.en => 'Paste migration package',
  };

  String get importPackage => switch (appLanguage) {
    AppLanguage.zhHans => '导入迁移包',
    AppLanguage.zhHant => '匯入遷移包',
    AppLanguage.en => 'Import package',
  };

  String packageGenerated(int count) => switch (appLanguage) {
    AppLanguage.zhHans => '已生成 $count 条便签的迁移包。',
    AppLanguage.zhHant => '已產生 $count 則便條的遷移包。',
    AppLanguage.en => 'Generated a package with $count notes.',
  };

  String get packageCopied => switch (appLanguage) {
    AppLanguage.zhHans => '迁移包已复制。',
    AppLanguage.zhHant => '遷移包已複製。',
    AppLanguage.en => 'Migration package copied.',
  };

  String packageImported(int count) => switch (appLanguage) {
    AppLanguage.zhHans => '已导入 $count 条便签。',
    AppLanguage.zhHant => '已匯入 $count 則便條。',
    AppLanguage.en => 'Imported $count notes.',
  };

  String get importProgressTitle => switch (appLanguage) {
    AppLanguage.zhHans => '正在导入',
    AppLanguage.zhHant => '正在匯入',
    AppLanguage.en => 'Importing',
  };

  String get importProgressDecrypting => switch (appLanguage) {
    AppLanguage.zhHans => '正在解密迁移包...',
    AppLanguage.zhHant => '正在解密遷移包...',
    AppLanguage.en => 'Decrypting migration package...',
  };

  String importProgressWriting(int imported, int total) =>
      switch (appLanguage) {
        AppLanguage.zhHans => '正在写入 $imported / $total 条便签',
        AppLanguage.zhHant => '正在寫入 $imported / $total 則便條',
        AppLanguage.en => 'Writing $imported / $total notes',
      };

  String importProgressDone(int count) => switch (appLanguage) {
    AppLanguage.zhHans => '已完成 $count 条便签',
    AppLanguage.zhHant => '已完成 $count 則便條',
    AppLanguage.en => 'Imported $count notes',
  };

  String get migrationFailed => switch (appLanguage) {
    AppLanguage.zhHans => '迁移失败，请检查迁移包和口令。',
    AppLanguage.zhHant => '遷移失敗，請檢查遷移包和口令。',
    AppLanguage.en => 'Migration failed. Check the package and passphrase.',
  };

  String get lanSendTitle => switch (appLanguage) {
    AppLanguage.zhHans => '局域网发送',
    AppLanguage.zhHant => '區域網路傳送',
    AppLanguage.en => 'Send over LAN',
  };

  String get lanReceiveTitle => switch (appLanguage) {
    AppLanguage.zhHans => '局域网接收',
    AppLanguage.zhHant => '區域網路接收',
    AppLanguage.en => 'Receive over LAN',
  };

  String get startLanSend => switch (appLanguage) {
    AppLanguage.zhHans => '开始局域网发送',
    AppLanguage.zhHant => '開始區域網路傳送',
    AppLanguage.en => 'Start LAN send',
  };

  String get stopLanSend => switch (appLanguage) {
    AppLanguage.zhHans => '停止发送',
    AppLanguage.zhHant => '停止傳送',
    AppLanguage.en => 'Stop sending',
  };

  String get lanAddress => switch (appLanguage) {
    AppLanguage.zhHans => '局域网地址',
    AppLanguage.zhHant => '區域網路地址',
    AppLanguage.en => 'LAN address',
  };

  String get alternativeLanAddress => switch (appLanguage) {
    AppLanguage.zhHans => '备用局域网地址',
    AppLanguage.zhHant => '備用區域網路地址',
    AppLanguage.en => 'Alternative LAN address',
  };

  String get lanAddressHint => switch (appLanguage) {
    AppLanguage.zhHans => '输入旧手机显示的局域网地址。两台手机需要在同一个 Wi-Fi 或热点内。',
    AppLanguage.zhHant => '輸入舊手機顯示的區域網路地址。兩台手機需要在同一個 Wi-Fi 或熱點內。',
    AppLanguage.en =>
      'Enter the address shown on the old phone. Both phones must be on the same Wi-Fi or hotspot.',
  };

  String get confirmationCode => switch (appLanguage) {
    AppLanguage.zhHans => '确认码',
    AppLanguage.zhHant => '確認碼',
    AppLanguage.en => 'Confirmation code',
  };

  String get noteCount => switch (appLanguage) {
    AppLanguage.zhHans => '便签数量',
    AppLanguage.zhHant => '便條數量',
    AppLanguage.en => 'Note count',
  };

  String get copyLanAddress => switch (appLanguage) {
    AppLanguage.zhHans => '复制地址',
    AppLanguage.zhHant => '複製地址',
    AppLanguage.en => 'Copy address',
  };

  String get fetchLanPackage => switch (appLanguage) {
    AppLanguage.zhHans => '获取迁移包',
    AppLanguage.zhHant => '取得遷移包',
    AppLanguage.en => 'Fetch package',
  };

  String get importFetchedPackage => switch (appLanguage) {
    AppLanguage.zhHans => '导入已获取迁移包',
    AppLanguage.zhHant => '匯入已取得遷移包',
    AppLanguage.en => 'Import fetched package',
  };

  String get confirmLanImportTitle => switch (appLanguage) {
    AppLanguage.zhHans => '确认导入？',
    AppLanguage.zhHant => '確認匯入？',
    AppLanguage.en => 'Confirm import?',
  };

  String confirmLanImportBody(String code, int count) => switch (appLanguage) {
    AppLanguage.zhHans => '请确认两台手机显示的确认码都是 $code，便签数量是 $count。确认后才会导入到本机。',
    AppLanguage.zhHant => '請確認兩台手機顯示的確認碼都是 $code，便條數量是 $count。確認後才會匯入到本機。',
    AppLanguage.en =>
      'Make sure both phones show confirmation code $code and note count $count. The notes will be imported to this device after confirmation.',
  };

  String get lanSendStarted => switch (appLanguage) {
    AppLanguage.zhHans => '局域网发送已开始。',
    AppLanguage.zhHant => '區域網路傳送已開始。',
    AppLanguage.en => 'LAN sending started.',
  };

  String get lanSendStopped => switch (appLanguage) {
    AppLanguage.zhHans => '局域网发送已停止。',
    AppLanguage.zhHant => '區域網路傳送已停止。',
    AppLanguage.en => 'LAN sending stopped.',
  };

  String get lanAddressCopied => switch (appLanguage) {
    AppLanguage.zhHans => '局域网地址已复制。',
    AppLanguage.zhHant => '區域網路地址已複製。',
    AppLanguage.en => 'LAN address copied.',
  };

  String get lanPackageFetched => switch (appLanguage) {
    AppLanguage.zhHans => '已获取迁移包，请核对确认码后导入。',
    AppLanguage.zhHant => '已取得遷移包，請核對確認碼後匯入。',
    AppLanguage.en =>
      'Fetched the package. Compare the confirmation code before importing.',
  };

  String get lanReceiveRequest => switch (appLanguage) {
    AppLanguage.zhHans => '收到接收请求',
    AppLanguage.zhHant => '收到接收請求',
    AppLanguage.en => 'Receive request',
  };

  String lanReceiveRequestBody(String address) => switch (appLanguage) {
    AppLanguage.zhHans =>
      address.isEmpty
          ? '新手机正在请求迁移包，允许后才会发送。'
          : '来自 $address 的设备正在请求迁移包，允许后才会发送。',
    AppLanguage.zhHant =>
      address.isEmpty
          ? '新手機正在請求遷移包，允許後才會傳送。'
          : '來自 $address 的裝置正在請求遷移包，允許後才會傳送。',
    AppLanguage.en =>
      address.isEmpty
          ? 'The new phone is requesting the migration package. It will be sent only after you allow it.'
          : 'A device from $address is requesting the migration package. It will be sent only after you allow it.',
  };

  String get scanLanQrCode => switch (appLanguage) {
    AppLanguage.zhHans => '扫描局域网二维码',
    AppLanguage.zhHant => '掃描區域網路 QR Code',
    AppLanguage.en => 'Scan LAN QR code',
  };

  String get scanLanQrCodeHint => switch (appLanguage) {
    AppLanguage.zhHans => '扫描旧手机显示的二维码。二维码只包含局域网地址，不包含便签内容。',
    AppLanguage.zhHant => '掃描舊手機顯示的 QR Code。QR Code 只包含區域網路地址，不包含便條內容。',
    AppLanguage.en =>
      'Scan the QR code shown on the old phone. It contains only the LAN address, not note content.',
  };

  String get scanLanQrCodeUnavailable => switch (appLanguage) {
    AppLanguage.zhHans => '当前设备无法启动扫码。请确认相机权限已开启，或返回后手动输入局域网地址。',
    AppLanguage.zhHant => '目前裝置無法啟動掃描。請確認相機權限已開啟，或返回後手動輸入區域網路地址。',
    AppLanguage.en =>
      'Scanner is unavailable on this device. Check camera permission, or go back and enter the LAN address manually.',
  };
}
