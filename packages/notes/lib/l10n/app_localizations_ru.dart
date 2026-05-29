// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appDisplayName => 'Private Notes (Nostr)';

  @override
  String get notUnlocked => 'Приложение не разблокировано';

  @override
  String get notePreviewCannotDecryptTitle =>
      'Не удалось расшифровать эту заметку';

  @override
  String get notePreviewCannotDecryptDescription =>
      'PIN/пароль необязателен: заметки без PIN остаются полностью совместимыми с NIP-44. Это может произойти из-за неверного PIN, рассинхронизации данных между устройствами или поврежденных/неполных данных заметки.';

  @override
  String get onboardingWelcomePageTitle =>
      'Добро пожаловать в\nPrivate Notes (Nostr)';

  @override
  String get onboardingWelcomePageDescription =>
      'Безопасно храните короткие заметки и пароли\n- шифрование, децентрализация, только для вас';

  @override
  String get onboardingWelcomePageOptionMD1 =>
      '✏️ **Создавайте** короткие заметки и пароли';

  @override
  String get onboardingWelcomePageOptionMD2 =>
      '🔐 **Шифруется** на вашем устройстве';

  @override
  String get onboardingWelcomePageOptionMD3 => '🌐 **Хранится** через Nostr';

  @override
  String get onboardingWelcomePageOptionMD4 =>
      '🧷 **Доступ** с помощью **nsec** и **PIN**';

  @override
  String get onboardingWelcomeButtonNext => 'Начать';

  @override
  String get onboardingSignUpPageTitle => 'Регистрация через Nostr';

  @override
  String get onboardingSignUpPageSubtitle => 'Что такое Nostr?';

  @override
  String get onboardingSignUpPageDescription =>
      'Nostr - это децентрализованная сеть для безопасного и устойчивого к цензуре общения. В отличие от традиционных платформ, Nostr не зависит от централизованных серверов - ваша личность и данные принадлежат только вам.';

  @override
  String get onboardingSignUpPageWhyTitle => 'Почему стоит войти через Nostr?';

  @override
  String get onboardingSignUpPageOptionMD1 =>
      '✅ **Мгновенный доступ** - в один клик создается приватный ключ. Без email и пароля.';

  @override
  String get onboardingSignUpPageOptionMD2 =>
      '🔐 **Вы владеете своей личностью** - ваш ключ и есть ваша личность. Ни одна компания не контролирует ваш аккаунт.';

  @override
  String get onboardingSignUpPageOptionMD3 =>
      '🌍 **Работает везде** - используйте один и тот же ключ во всех приложениях на Nostr';

  @override
  String get onboardingSignUpButtonGenerateKey => 'Создать ключ Nostr';

  @override
  String get apkDistributionTitle => 'Скачать APK';

  @override
  String get apkDistributionDescription =>
      'Вы можете скачать установочный файл напрямую. Рекомендуется проверить контрольную сумму SHA-256 после скачивания.';

  @override
  String get apkDistributionDownloadButton => 'Скачать .apk';

  @override
  String get apkDistributionViewChecksum =>
      'Посмотреть контрольную сумму (SHA-256)';

  @override
  String get appStoreBannerTitle => 'Доступно в App Store';

  @override
  String get appStoreBannerButton => 'Открыть в AppStore';

  @override
  String get apkBannerTitle => 'Android APK';

  @override
  String get apkBannerButton => 'Скачать APK';

  @override
  String get onboardingSignUpAlreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get onboardingSignUpButtonLogin => 'Войти';

  @override
  String get onboardingShowNsecPageTitle => 'Ваш приватный ключ Nostr (Nsec)';

  @override
  String get onboardingShowNsecPageDescription =>
      'Сохраните этот ключ в надежном месте. Ключ nsec дает полный контроль и владение вашими данными.';

  @override
  String get onboardingShowNsecPageOptionMD1 =>
      '🔑 **Обязателен** - этот ключ является паролем вашего аккаунта и нужен для входа.';

  @override
  String get onboardingShowNsecPageOptionMD2 =>
      '📌 **Постоянный** - храните резервную копию. Мы не можем изменить или восстановить его.';

  @override
  String get onboardingShowNsecPageOptionMD3 =>
      '🚫 **Приватный** - любой, у кого есть этот ключ, получит доступ к аккаунту. Никому не передавайте его.';

  @override
  String get onboardingShowNsecPageButtonCopyKey => 'Скопировать ключ';

  @override
  String get onboardingShowNsecPageKeyCopied => 'Ключ скопирован';

  @override
  String get onboardingNsecPageTitle => 'Введите ваш Nostr nsec';

  @override
  String get onboardingNsecPageDescription =>
      'Ваш приватный ключ используется для шифрования и подписи заметок. Он принадлежит только вам и никогда не покидает устройство';

  @override
  String get onboardingNsecPageTextFieldHint => 'nsec1...';

  @override
  String get onboardingNsecPageLabelHint =>
      'Можно импортировать из другого приложения или вставить вручную';

  @override
  String get onboardingNsecPageDontHaveAccount => 'Нет аккаунта?';

  @override
  String get onboardingNsecPageButtonSignUp => 'Зарегистрироваться';

  @override
  String get onboardingPinPageTitle => 'Задайте PIN или пароль';

  @override
  String get onboardingPinPageDescription =>
      'Это добавляет дополнительный слой шифрования - даже если кто-то получит ваш nsec, заметки останутся защищенными';

  @override
  String get onboardingPinPageTextFieldHint => 'PIN или пароль';

  @override
  String get onboardingPinPageLabelCheckboxUsePin =>
      'Использовать PIN для разблокировки';

  @override
  String get onboardingPinPageInfoPin =>
      'PIN - это дополнительный уровень защиты на случай компрометации nsec. Он хранится только в памяти и никогда не сохраняется на диск. Если PIN утерян, существующие заметки расшифровать нельзя. Если создать или изменить заметку с неверным PIN, она будет зашифрована с этим неверным PIN.';

  @override
  String get errorEmptyNsec => 'Ключ NSEC не может быть пустым';

  @override
  String get errorInvalidNsecFormat => 'Неверный формат ключа NSEC';

  @override
  String get errorInvalidPrivateKey => 'Неверный приватный ключ';

  @override
  String get errorEmptyPubkey => 'Публичный ключ не может быть пустым';

  @override
  String get errorEmptyPin => 'PIN или пароль не может быть пустым';

  @override
  String errorInvalidPinFormatMinCount(String minCount) {
    return 'PIN или пароль должен содержать минимум $minCount символов';
  }

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get settingsScreenSectionSettingsTitle => 'Настройки';

  @override
  String get settingsScreenSectionSessionTitle => 'Сеанс';

  @override
  String get settingsScreenSectionAccountTitle => 'Аккаунт';

  @override
  String get settingsScreenExit => 'Заблокировать приложение';

  @override
  String get settingsScreenLogout => 'Выйти';

  @override
  String get settingsScreenLogoutDescription =>
      'Удалить приватный ключ с этого устройства';

  @override
  String get settingsScreenLogoutConfirmationMessage =>
      'Вы действительно хотите выйти и очистить все данные? Это действие нельзя отменить.\nУбедитесь, что вы сохранили nsec и PIN - если потерять любой из них, данные будут утеряны навсегда.';

  @override
  String get settingsScreenDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsScreenDeleteDescription =>
      'Удалить заметки с реле и очистить локальные данные';

  @override
  String get settingsScreenDeleteAccountConfirmationMessage =>
      'Это действие навсегда удалит ваш аккаунт с устройства и инициирует удаление данных из сети **Nostr**.\n\n### Что произойдет:\n- **Локально:** ваш **приватный ключ** и все заметки будут безвозвратно удалены с этого устройства.\n- **В сети Nostr:** на ваши реле будет отправлен запрос на удаление всех заметок. Большинство реле выполнят этот запрос.\n\n### Важно:\nВаши заметки зашифрованы сквозным шифрованием. Даже если копии останутся на некоторых реле, без приватного ключа (который хранился только в Keychain и теперь удален) их невозможно прочитать.';

  @override
  String get settingsScreenDeleteAccountStatusPreparing =>
      'Сбор заметок для удаления...';

  @override
  String get settingsScreenDeleteAccountStatusKind5Publishing =>
      'Публикация запросов на удаление...';

  @override
  String get settingsScreenDeleteAccountStatusClearLocalStorages =>
      'Очистка локальных данных...';

  @override
  String get settingsScreenDeleteAccountStatusLogout => 'Выход...';

  @override
  String get settingsItemPreferences => 'Предпочтения';

  @override
  String get settingsItemHelp => 'Помощь';

  @override
  String get settingsItemContacts => 'Контакты';

  @override
  String get settingsItemBuyMeACoffee => 'Купить мне кофе ☕';

  @override
  String get settingsItemDonateBTC => 'Поддержать через Lightning ⚡';

  @override
  String get settingsItemContactsLabelContacts => 'Контакты';

  @override
  String get settingsItemContactsContactsMd =>
      '- 📧 Email: [alexey.yu.popkov@gmail.com](mailto:alexey.yu.popkov@gmail.com)\n- 📱 Telegram: [@alexey_yu_popkov](https://t.me/alexey_yu_popkov)\n- 💼 LinkedIn: [https://www.linkedin.com/in/alekseii-popkov-57007282](https://www.linkedin.com/in/alekseii-popkov-57007282)';

  @override
  String get settingsItemContactsLabelFAQ => 'Частые вопросы';

  @override
  String get settingsItemContactsMdFaq =>
      '\n\n- Забыли PIN? Восстановить заметки нельзя — PIN нигде не хранится.\n- Потеряли nsec? Без приватного ключа восстановление невозможно.';

  @override
  String get preferencesScreenItemRelays => 'Подключенные реле';

  @override
  String get preferencesScreenItemLanguage => 'Язык';

  @override
  String get preferencesScreenLanguageSystem => 'Системный';

  @override
  String get preferencesScreenLanguageEnglish => 'English';

  @override
  String get preferencesScreenLanguageRussian => 'Русский';

  @override
  String get preferencesScreenItemMobilePinKeyboardType => 'Тип клавиатуры PIN';

  @override
  String get pinKeyboardTypeScreenTitle => 'Тип клавиатуры PIN';

  @override
  String get pinKeyboardTypeScreenDescription =>
      'Выберите тип клавиатуры при вводе PIN';

  @override
  String get pinKeyboardTypeText => 'Обычная (текст)';

  @override
  String get pinKeyboardTypeNumber => 'Числовая';

  @override
  String get pinKeyboardTypePhone => 'Телефонная';

  @override
  String get noteScreenErrorNoteContentCannotBeEmpty =>
      'Содержимое заметки не может быть пустым';

  @override
  String get errorPublishOperationTimedOut =>
      'Истекло время ожидания публикации';

  @override
  String get notesListPendingSyncTitle => 'Ожидает синхронизации';

  @override
  String get notesListPendingSyncDescription =>
      'Эта заметка еще не синхронизирована с сетью';

  @override
  String get notesListDecryptLikelyReasonLabel => 'Вероятная причина';

  @override
  String get notesListDecryptDetailsLabel => 'Детали';

  @override
  String get notesListDecryptReasonWrongPin =>
      'Неверный PIN/пароль или несоответствующий контекст шифрования для этой заметки.';

  @override
  String get notesListDecryptReasonCorruptedPayload =>
      'Полезная нагрузка заметки выглядит поврежденной, неполной или созданной в неподдерживаемом формате.';

  @override
  String get notesListDecryptReasonInvalidParams =>
      'Криптографические параметры для этой заметки недействительны.';

  @override
  String get editNoteScreenSaveSuccess => 'Заметка успешно сохранена!';

  @override
  String get credentialsDataScreenTitle => 'Данные учетной записи';

  @override
  String get credentialsDataScreenLabelNsec => 'Nsec';

  @override
  String get credentialsDataScreenLabelPrivateKey => 'Приватный ключ';

  @override
  String get credentialsDataScreenLabelPubKey => 'Публичный ключ';

  @override
  String get credentialsDataScreenLabelPin => 'PIN';

  @override
  String get credentialsDataScreenWarningNsec =>
      'Ваш nsec (приватный ключ) хранится только на этом устройстве в защищенном хранилище (Keychain на iOS, Keystore на Android). Он никогда не отправляется на сервер. Потеря nsec означает безвозвратную потерю доступа ко всем данным.';

  @override
  String get credentialsDataScreenWarningPin =>
      'PIN - это дополнительный уровень защиты при компрометации nsec. Он хранится только в памяти и никогда не сохраняется на диск. Если PIN потерян, существующие заметки нельзя расшифровать. Если создать или изменить заметку с неверным PIN, она будет зашифрована неверным PIN.';

  @override
  String get credentialsDataScreenWarningPrivateKey =>
      'Приватный ключ - это hex-представление вашего nsec. Оба формата дают полный доступ к аккаунту.';

  @override
  String get credentialsDataScreenInfoPubKey =>
      'Ваш публичный ключ однозначно идентифицирует аккаунт в сети Nostr. Им безопасно делиться - любой может использовать его, чтобы найти и проверить ваши публикации.';

  @override
  String get helpScreenTitle => 'Помощь';

  @override
  String get helpScreenContent =>
      '# Private Notes (Nostr)\n\nPrivate Notes (Nostr) - это приватное приложение для заметок с шифрованием, построенное на протоколе **Nostr**. Ваши заметки шифруются на устройстве и синхронизируются через децентрализованные реле - ни одна компания не владеет вашими данными.\n\n\n## Что такое Nostr?\n\nNostr (Notes and Other Stuff Transmitted by Relays) - открытый децентрализованный протокол. Вместо центрального сервера он использует сеть **реле** - независимых серверов, которые хранят и пересылают данные. Ваша идентичность - это криптографическая пара ключей, а не email или номер телефона.\n\n\n## Ключевые понятия\n\n### 🔑 Nsec (приватный ключ)\n\nВаш **nsec** - это главный ключ. Он начинается с `nsec1...` и является bech32-представлением вашего приватного ключа (hex). Он используется для:\n\n- **Подписи** заметок, чтобы реле могли подтвердить, что они от вас\n- **Шифрования** и **расшифровки** содержимого заметок\n- **Подтверждения владения** аккаунтом\n\n> ⚠️ **Никогда не передавайте nsec никому.** Любой, у кого есть этот ключ, получает полный контроль над аккаунтом. Здесь нет \"забыл пароль\" - если потерять nsec, данные будут утеряны навсегда.\n\nВаш nsec хранится только на этом устройстве в защищенном хранилище (Keychain на iOS, Keystore на Android). Он никогда не отправляется на сервер.\n\n### 🌐 Публичный ключ (npub)\n\nВаш **публичный ключ** (отображается как `npub1...`) - это публичная идентичность в сети Nostr. Он вычисляется из nsec и безопасен для передачи другим. Любой может использовать его, чтобы найти ваш профиль в приложениях Nostr.\n\n### 🔒 PIN / Пароль\n\nPIN дает **дополнительный уровень шифрования** поверх nsec. Даже если кто-то получит приватный ключ, без PIN он не сможет прочитать ваши заметки.\n\nВажно:\n\n- PIN **никогда не сохраняется на диск** - он живет только в памяти, пока приложение открыто\n- Если **забыть PIN**, существующие заметки **невозможно расшифровать**\n- Если ввести **неверный PIN**, новые или измененные заметки зашифруются этим неверным PIN и не откроются с правильным\n\n### 📡 Реле\n\nРеле - это серверы, которые хранят и доставляют ваши зашифрованные заметки. Вы можете выбирать реле в **Настройки → Предпочтения → Подключенные реле**. Использование нескольких реле повышает надежность: если одно недоступно, данные останутся на других.\n\n\n## Как это работает\n\n1. **Создаете** заметку в редакторе\n2. Заметка **шифруется** на устройстве с помощью NIP-44 и ваших nsec/PIN\n3. Зашифрованная заметка **подписывается** и **публикуется** в выбранные реле\n4. При открытии приложения заметки **загружаются** с реле и **расшифровываются** локально\n\nНикто - ни операторы реле, ни мы - не может прочитать ваши заметки. Расшифровать их можете только вы, имея nsec и PIN.\n\n\n## Рекомендации\n\n- **Сделайте резервную копию nsec** в безопасном месте (например, менеджере паролей). Без него восстановить аккаунт нельзя.\n- **Помните свой PIN.** Он нигде не хранится и не подлежит сбросу.\n- **Используйте несколько реле** для лучшей доступности и резервирования.\n- Ваш nsec работает во всех приложениях Nostr - можно использовать одну и ту же идентичность везде.';

  @override
  String get notesListScreenTitle => 'Заметки';

  @override
  String get notesListTabAll => 'Все';

  @override
  String get notesListTabFolders => 'Папки';

  @override
  String get notesFoldersEmptyStatePlaceholder =>
      'Назначайте метки заметкам, чтобы группировать их по папкам';

  @override
  String get homeScreenEmptyStatePlaceholder =>
      'Нажмите +, чтобы создать заметку';

  @override
  String get notesListSectionToday => 'Сегодня';

  @override
  String get notesListSectionPrevious7Days => 'Предыдущие 7 дней';

  @override
  String get notesListSectionPrevious30Days => 'Предыдущие 30 дней';

  @override
  String get notesListSectionOther => 'Другое';

  @override
  String get notesListConfirmationDialogDeletion =>
      'Вы уверены, что хотите удалить эту заметку? Действие нельзя отменить.';

  @override
  String get notesListAssignFolder => 'Папка';

  @override
  String get privacyPolicyScreenTitle => 'Политика конфиденциальности';

  @override
  String get classificationClassFinance => 'Финансы';

  @override
  String get classificationClassJournal => 'Дневник';

  @override
  String get classificationClassPersonal => 'Личное';

  @override
  String get classificationClassSecurity => 'Безопасность';

  @override
  String get classificationClassTravel => 'Путешествия';

  @override
  String get classificationClassWork => 'Работа';

  @override
  String get classificationClassBookmarks => 'Закладки';

  @override
  String get classificationClassOther => 'Другое';

  @override
  String get notePreviewMoreMenuAssignFolder => 'Назначить папку';

  @override
  String get notePreviewMoreMenuCopyContent => 'Скопировать содержимое';

  @override
  String get notePreviewMoreMenuInfo => 'Информация';

  @override
  String get donateLightningScreenTitle => 'Поддержать через Lightning ⚡';

  @override
  String get donateLightningScreenSubtitle =>
      'Поддержите разработку Lightning-платежом';

  @override
  String get donateLightningScreenErrorInvoice => 'Не удалось создать инвойс';

  @override
  String get donateLightningScreenInputHint => 'Сумма (сат)';

  @override
  String get donateLightningScreenWalletSectionTitle => 'Открыть в кошельке';

  @override
  String donateLightningScreenSubmitButtonOpenInWallet(String walletName) {
    return 'Открыть в $walletName';
  }

  @override
  String get donateLightningScreenSubmitButtonGenerateInvoice =>
      'Создать инвойс';

  @override
  String get donateLightningScreenButtonEditAmount => 'Изменить сумму';

  @override
  String get donateLightningScreenButtonCopyInvoice => 'Скопировать инвойс';

  @override
  String get donateLightningScreenButtonOpenWithLightning =>
      'Открыть через Lightning';

  @override
  String get donateLightningScreenQrInstruction =>
      'Сканируйте QR-код в вашем Lightning-кошельке на телефоне.';

  @override
  String get donateLightningScreenMessageInvoiceCopied => 'Инвойс скопирован';
}
