// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appDisplayName => 'Private Notes (Nostr)';

  @override
  String get notUnlocked => 'Приложението не е отключено';

  @override
  String get notePreviewCannotDecryptTitle =>
      'Тази бележка не може да бъде декриптирана';

  @override
  String get notePreviewCannotDecryptDescription =>
      'ПИН/паролата е незадължителна: бележките без ПИН остават напълно съвместими с NIP-44. Това може да се дължи на грешен ПИН, несъответствие на данни между устройства или повредени/непълни данни на бележката.';

  @override
  String get onboardingWelcomePageTitle =>
      'Добре дошли в\nPrivate Notes (Nostr)';

  @override
  String get onboardingWelcomePageDescription =>
      'Безопасно съхранявайте кратки бележки и пароли\n– криптирани, децентрализирани, само за вас';

  @override
  String get onboardingWelcomePageOptionMD1 =>
      '✏️ **Създавайте** кратки бележки и пароли';

  @override
  String get onboardingWelcomePageOptionMD2 =>
      '🔐 **Криптирани** на вашето устройство';

  @override
  String get onboardingWelcomePageOptionMD3 => '🌐 **Съхранявани** чрез Nostr';

  @override
  String get onboardingWelcomePageOptionMD4 =>
      '🧷 **Достъп** с помощта на **nsec** и **ПИН**';

  @override
  String get onboardingWelcomeButtonNext => 'Начало';

  @override
  String get onboardingSignUpPageTitle => 'Регистрация чрез Nostr';

  @override
  String get onboardingSignUpPageSubtitle => 'Какво е Nostr?';

  @override
  String get onboardingSignUpPageDescription =>
      'Nostr е децентрализирана мрежа за сигурна и устойчива на цензура комуникация. За разлика от традиционните платформи, Nostr не разчита на централизирани сървъри – вашата самоличност и данни принадлежат само на вас.';

  @override
  String get onboardingSignUpPageWhyTitle => 'Защо да влезете чрез Nostr?';

  @override
  String get onboardingSignUpPageOptionMD1 =>
      '✅ **Незабавен достъп** – с един клик се генерира личен ключ. Без имейл и парола.';

  @override
  String get onboardingSignUpPageOptionMD2 =>
      '🔐 **Притежавате своята самоличност** – вашият ключ е вашата самоличност. Никоя компания не контролира акаунта ви.';

  @override
  String get onboardingSignUpPageOptionMD3 =>
      '🌍 **Работи навсякъде** – използвайте един и същ ключ във всички приложения, базирани на Nostr';

  @override
  String get onboardingSignUpButtonGenerateKey => 'Генерирай Nostr ключ';

  @override
  String get apkDistributionTitle => 'Изтегли APK';

  @override
  String get apkDistributionDescription =>
      'Можете да изтеглите инсталационния файл директно. Препоръчително е да проверите SHA-256 контролната сума след изтеглянето.';

  @override
  String get apkDistributionDownloadButton => 'Изтегли .apk';

  @override
  String get apkDistributionViewChecksum => 'Виж контролна сума (SHA-256)';

  @override
  String get appStoreBannerTitle => 'Достъпно в App Store';

  @override
  String get appStoreBannerButton => 'Отвори в AppStore';

  @override
  String get apkBannerTitle => 'Android APK';

  @override
  String get apkBannerButton => 'Изтегли APK';

  @override
  String get onboardingSignUpAlreadyHaveAccount => 'Вече имате акаунт?';

  @override
  String get onboardingSignUpButtonLogin => 'Вход';

  @override
  String get onboardingShowNsecPageTitle => 'Вашият личен Nostr ключ (Nsec)';

  @override
  String get onboardingShowNsecPageDescription =>
      'Запазете този ключ на сигурно място. Вашият nsec ви дава пълен контрол и собственост върху данните.';

  @override
  String get onboardingShowNsecPageOptionMD1 =>
      '🔑 **Задължителен** – този ключ е паролата на акаунта ви и е необходим за влизане.';

  @override
  String get onboardingShowNsecPageOptionMD2 =>
      '📌 **Постоянен** – съхранявайте резервно копие. Не можем да го сменим или възстановим.';

  @override
  String get onboardingShowNsecPageOptionMD3 =>
      '🚫 **Личен** – всеки, притежаващ този ключ, ще получи достъп до акаунта ви. Никога не го споделяйте.';

  @override
  String get onboardingShowNsecPageButtonCopyKey => 'Копирай ключ';

  @override
  String get onboardingShowNsecPageKeyCopied => 'Ключът е копиран в клипборда';

  @override
  String get onboardingNsecPageTitle => 'Въведете вашия Nostr nsec';

  @override
  String get onboardingNsecPageDescription =>
      'Вашият личен ключ се използва за криптиране и подписване на бележки. Той принадлежи само на вас и никога не напуска устройството';

  @override
  String get onboardingNsecPageTextFieldHint => 'nsec1...';

  @override
  String get onboardingNsecPageLabelHint =>
      'Можете да импортирате от друго приложение или да го въведете ръчно';

  @override
  String get onboardingNsecPageDontHaveAccount => 'Нямате акаунт?';

  @override
  String get onboardingNsecPageButtonSignUp => 'Регистрирай се';

  @override
  String get onboardingNsecPageValidationEmpty =>
      'Ключът NSEC не може да е празен';

  @override
  String get onboardingNsecPageValidationNpub =>
      'Това е публичен ключ (npub). Въведете вашия частен ключ (nsec)';

  @override
  String get onboardingNsecPageValidationInvalid => 'Невалиден ключ NSEC';

  @override
  String get onboardingPinPageTitle => 'Задайте ПИН или парола';

  @override
  String get onboardingPinPageDescription =>
      'Това добавя допълнителен слой криптиране – дори ако някой получи вашия nsec, бележките ви ще останат защитени';

  @override
  String get onboardingPinPageTextFieldHint => 'ПИН или парола';

  @override
  String get onboardingPinPageLabelCheckboxUsePin =>
      'Използвай ПИН за отключване';

  @override
  String get onboardingPinPageInfoPin =>
      'ПИН-ът е допълнителен слой защита при компрометиране на nsec. Той се съхранява само в паметта и никога не се записва на диск. Ако ПИН-ът бъде изгубен, съществуващите бележки не могат да бъдат декриптирани. Ако създадете или промените бележка с грешен ПИН, тя ще бъде криптирана с грешния ПИН.';

  @override
  String get errorEmptyNsec => 'NSEC ключът не може да бъде празен';

  @override
  String get errorInvalidNsecFormat => 'Невалиден формат на NSEC ключ';

  @override
  String get errorInvalidPrivateKey => 'Невалиден личен ключ';

  @override
  String get errorEmptyPubkey => 'Публичният ключ не може да бъде празен';

  @override
  String get errorEmptyPin => 'ПИН или паролата не може да бъде празна';

  @override
  String errorInvalidPinFormatMinCount(String minCount) {
    return 'ПИН или паролата трябва да съдържа поне $minCount символа';
  }

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get settingsScreenSectionSettingsTitle => 'Настройки';

  @override
  String get settingsScreenSectionSessionTitle => 'Сесия';

  @override
  String get settingsScreenSectionAccountTitle => 'Акаунт';

  @override
  String get settingsScreenExit => 'Заключи приложението';

  @override
  String get settingsScreenLogout => 'Изход';

  @override
  String get settingsScreenLogoutDescription =>
      'Премахни личния ключ от това устройство';

  @override
  String get settingsScreenLogoutConfirmationMessage =>
      'Наистина ли искате да излезете и да изтриете всички данни? Това действие не може да бъде отменено.\nУверете се, че сте запазили своя nsec и ПИН – ако загубите някое от тях, данните ви ще бъдат загубени завинаги.';

  @override
  String get settingsScreenDeleteAccount => 'Изтрий акаунт';

  @override
  String get settingsScreenDeleteDescription =>
      'Изтрий бележки от релетата и изчисти локалните данни';

  @override
  String get settingsScreenDeleteAccountConfirmationMessage =>
      'Това действие ще изтрие акаунта ви от устройството завинаги и ще инициира изтриване на данни от мрежата **Nostr**.\n\n### Какво ще се случи:\n- **Локално:** вашият **личен ключ** и всички бележки ще бъдат безвъзвратно изтрити от устройството.\n- **В Nostr мрежата:** до вашите релета ще бъдат изпратени заявки за изтриване на всички бележки. Повечето релета ще изпълнят тази заявка.\n\n### Важно:\nВашите бележки са криптирани end-to-end. Дори ако копия останат на някои релета, без личния ключ (съхраняван само в Keychain и вече изтрит) те не могат да бъдат прочетени.';

  @override
  String get settingsScreenDeleteAccountStatusPreparing =>
      'Събиране на бележки за изтриване...';

  @override
  String get settingsScreenDeleteAccountStatusKind5Publishing =>
      'Публикуване на заявки за изтриване...';

  @override
  String get settingsScreenDeleteAccountStatusClearLocalStorages =>
      'Изчистване на локалните данни...';

  @override
  String get settingsScreenDeleteAccountStatusLogout => 'Излизане...';

  @override
  String get settingsItemPreferences => 'Предпочитания';

  @override
  String get settingsItemHelp => 'Помощ';

  @override
  String get settingsItemContacts => 'Контакти';

  @override
  String get settingsItemBuyMeACoffee => 'Купи ми кафе ☕';

  @override
  String get settingsItemDonateBTC => 'Поддръжка чрез Lightning ⚡';

  @override
  String get settingsItemContactsLabelContacts => 'Контакти';

  @override
  String get settingsItemContactsContactsMd =>
      '- 📧 Имейл: [alexey.yu.popkov@gmail.com](mailto:alexey.yu.popkov@gmail.com)\n- 📱 Telegram: [@alexey_yu_popkov](https://t.me/alexey_yu_popkov)\n- 💼 LinkedIn: [https://www.linkedin.com/in/alekseii-popkov-57007282](https://www.linkedin.com/in/alekseii-popkov-57007282)';

  @override
  String get settingsItemContactsLabelFAQ => 'Чести въпроси';

  @override
  String get settingsItemContactsMdFaq =>
      '\n\n- Забравили ПИН? Бележките не могат да бъдат възстановени – ПИН-ът никъде не се съхранява.\n- Загубили nsec? Без личния ключ акаунтът не може да бъде възстановен.';

  @override
  String get preferencesScreenItemRelays => 'Свързани релета';

  @override
  String get preferencesScreenItemLanguage => 'Език';

  @override
  String get preferencesScreenLanguageSystem => 'Системен';

  @override
  String get preferencesScreenLanguageEnglish => 'English';

  @override
  String get preferencesScreenLanguageRussian => 'Русский';

  @override
  String get preferencesScreenLanguageBulgarian => 'Български';

  @override
  String get preferencesScreenItemMobilePinKeyboardType =>
      'Тип клавиатура за ПИН';

  @override
  String get pinKeyboardTypeScreenTitle => 'Тип клавиатура за ПИН';

  @override
  String get pinKeyboardTypeScreenDescription =>
      'Изберете типа клавиатура, показвана при въвеждане на вашия ПИН';

  @override
  String get pinKeyboardTypeText => 'По подразбиране (Текст)';

  @override
  String get pinKeyboardTypeNumber => 'Цифрова';

  @override
  String get pinKeyboardTypePhone => 'Телефонна';

  @override
  String get noteScreenErrorNoteContentCannotBeEmpty =>
      'Съдържанието на бележката не може да бъде празно';

  @override
  String get errorPublishOperationTimedOut => 'Времето за публикуване изтече';

  @override
  String get exportImportScreenTitle => 'Износ и внос';

  @override
  String get exportImportSectionExportTitle => 'Износ';

  @override
  String get exportImportSectionImportTitle => 'Внос';

  @override
  String get exportImportItemExportTitle => 'Изнеси всички бележки';

  @override
  String get exportImportItemExportSubtitle =>
      'Износ на всички бележки в защитен с парола ZIP архив. Бележките се криптират с AES-256-CBC. Ако паролата не е зададена, архивът ще бъде създаден без криптиране.';

  @override
  String get exportImportItemImportTitle => 'Внеси всички бележки';

  @override
  String get exportImportItemImportSubtitle =>
      'Възстанови бележки от предварително изнесен архив.';

  @override
  String get exportImportSectionDataTitle => 'Данни';

  @override
  String get exportImportPasswordDialogTitle => 'Задай парола за износ';

  @override
  String get exportImportPasswordDialogHint =>
      'Оставете празно за износ без криптиране';

  @override
  String get exportImportPasswordDialogTextFieldHint =>
      'Парола (незадължително)';

  @override
  String get exportImportExportFileNameHint => 'Име на файл (незадължително)';

  @override
  String get exportImportExportFileNameInvalid =>
      'Въведете валидно име на файл';

  @override
  String get exportImportExportEmptyError => 'Няма бележки за износ';

  @override
  String get exportImportExportEncryptionError =>
      'Неуспешно криптиране на резервното копие. Опитайте отново.';

  @override
  String get exportImportExportFileError =>
      'Неуспешно създаване на файла с резервно копие. Опитайте отново.';

  @override
  String get exportImportImportInvalidFileError =>
      'Този файл не е валидно резервно копие на бележки.';

  @override
  String get exportImportImportWrongPasswordError =>
      'Грешна парола или резервното копие е повредено.';

  @override
  String get exportImportImportAuthError =>
      'За да внесете бележки, трябва да влезете в акаунта.';

  @override
  String get exportImportImportFileNotFoundError => 'Файлът не е намерен.';

  @override
  String get exportImportImportSuccess => 'Бележките са успешно внесени';

  @override
  String get exportImportExportSuccess => 'Бележките са успешно изнесени';

  @override
  String get exportImportShareUnavailable =>
      'Функцията за споделяне не е налична на това устройство';

  @override
  String get exportImportWebDownloaded =>
      'Файлът ще бъде записан в папката «Изтегляния».';

  @override
  String get exportImportImportDialogTitle => 'Внос на бележки';

  @override
  String get exportImportImportDialogPasswordHint =>
      'Оставете празно, ако резервното копие е без парола';

  @override
  String get exportImportImportDialogPasswordFieldHint =>
      'Парола (ако е криптирано)';

  @override
  String get exportImportImportDialogPolicyLabel =>
      'Ако бележката вече съществува:';

  @override
  String get exportImportImportPolicyMergeTitle => 'Обедини съдържанието';

  @override
  String get exportImportImportPolicyMergeSubtitle =>
      'Добави внесения текст под съществуващата бележка';

  @override
  String get exportImportImportPolicyKeepIncomingTitle => 'Запази внесената';

  @override
  String get exportImportImportPolicyKeepIncomingSubtitle =>
      'Презапиши съществуващите бележки с внесените';

  @override
  String get exportImportImportPolicyKeepExistingTitle =>
      'Запази съществуващата';

  @override
  String get exportImportImportPolicyKeepExistingSubtitle =>
      'Пропусни внесените бележки, които вече съществуват локално';

  @override
  String exportImportPasswordTooShort(String count) {
    return 'Паролата трябва да съдържа поне $count символа';
  }

  @override
  String get exportImportNoPasswordWarning =>
      'Без парола бележките ще бъдат изнесени в отворен вид и всеки, получил файла, ще може да ги прочете.';

  @override
  String get notesListPendingSyncTitle => 'Очаква синхронизация';

  @override
  String get notesListPendingSyncDescription =>
      'Тази бележка все още не е синхронизирана с мрежата';

  @override
  String get notesListDecryptLikelyReasonLabel => 'Вероятна причина';

  @override
  String get notesListDecryptDetailsLabel => 'Детайли';

  @override
  String get notesListDecryptReasonWrongPin =>
      'Грешен ПИН/парола или несъответстващ контекст на криптиране за тази бележка.';

  @override
  String get notesListDecryptReasonCorruptedPayload =>
      'Данните на бележката изглеждат повредени, непълни или създадени в неподдържан формат.';

  @override
  String get notesListDecryptReasonInvalidParams =>
      'Криптографските параметри за тази бележка са невалидни.';

  @override
  String get notesListSomeNotesDecryptFailed =>
      'Неуспешно декриптиране на някои бележки. Проверете ПИН-а.';

  @override
  String get editNoteScreenSaveSuccess => 'Бележката е успешно запазена!';

  @override
  String get credentialsDataScreenTitle => 'Данни на акаунта';

  @override
  String get credentialsDataScreenLabelNsec => 'Nsec';

  @override
  String get credentialsDataScreenLabelPrivateKey => 'Личен ключ';

  @override
  String get credentialsDataScreenLabelPubKey => 'Публичен ключ';

  @override
  String get credentialsDataScreenLabelPin => 'ПИН';

  @override
  String get credentialsDataScreenWarningNsec =>
      'Вашият nsec (личен ключ) се съхранява само на това устройство в защитено хранилище (Keychain на iOS, Keystore на Android). Той никога не се изпраща до сървър. Загубата на nsec означава безвъзвратна загуба на достъп до всички данни.';

  @override
  String get credentialsDataScreenWarningPin =>
      'ПИН-ът е допълнителен слой защита при компрометиране на nsec. Той се съхранява само в паметта и никога не се записва на диск. Ако ПИН-ът бъде изгубен, съществуващите бележки не могат да бъдат декриптирани. Ако създадете или промените бележка с грешен ПИН, тя ще бъде криптирана с грешния ПИН.';

  @override
  String get credentialsDataScreenWarningPrivateKey =>
      'Личният ключ е hex-представяне на вашия nsec. И двата формата осигуряват пълен достъп до акаунта.';

  @override
  String get credentialsDataScreenInfoPubKey =>
      'Вашият публичен ключ уникално идентифицира акаунта в Nostr мрежата. Безопасно е да го споделяте – всеки може да го използва, за да намери и провери вашите публикации.';

  @override
  String get helpScreenTitle => 'Помощ';

  @override
  String get helpScreenContent =>
      '# Private Notes (Nostr)\n\nPrivate Notes (Nostr) е приложение за частни бележки с криптиране, изградено на протокола **Nostr**. Вашите бележки се криптират на устройството и се синхронизират чрез децентрализирани релета – никоя компания не притежава вашите данни.\n\n\n## Какво е Nostr?\n\nNostr (Notes and Other Stuff Transmitted by Relays) е отворен децентрализиран протокол. Вместо централен сървър той използва мрежа от **релета** – независими сървъри, съхраняващи и препредаващи данни. Вашата самоличност е криптографска двойка ключове, а не имейл или телефонен номер.\n\n\n## Основни понятия\n\n### 🔑 Nsec (личен ключ)\n\nВашият **nsec** е главният ключ. Той започва с `nsec1...` и е bech32-представяне на вашия личен ключ (hex). Използва се за:\n\n- **Подписване** на бележки, за да могат релетата да потвърдят, че са от вас\n- **Криптиране** и **декриптиране** на съдържанието на бележките\n- **Потвърждаване на собствеността** върху акаунта\n\n> ⚠️ **Никога не споделяйте nsec с никого.** Всеки, притежаващ този ключ, получава пълен контрол над акаунта. Тук няма \"забравена парола\" – ако загубите nsec, данните ще бъдат загубени завинаги.\n\nВашият nsec се съхранява само на това устройство в защитено хранилище (Keychain на iOS, Keystore на Android). Той никога не се изпраща до сървър.\n\n### 🌐 Публичен ключ (npub)\n\nВашият **публичен ключ** (показва се като `npub1...`) е публичната ви самоличност в Nostr мрежата. Той се изчислява от nsec и е безопасно да го споделяте. Всеки може да го използва, за да намери вашия профил в Nostr приложения.\n\n### 🔒 ПИН / Парола\n\nПИН-ът осигурява **допълнителен слой криптиране** върху nsec. Дори ако някой получи личния ключ, без ПИН-а не може да прочете вашите бележки.\n\nВажно:\n\n- ПИН-ът **никога не се записва на диск** – съществува само в паметта, докато приложението е отворено\n- Ако **забравите ПИН-а**, съществуващите бележки **не могат да бъдат декриптирани**\n- Ако въведете **грешен ПИН**, новите или променените бележки ще бъдат криптирани с грешния ПИН и няма да се отворят с правилния\n\n### 📡 Релета\n\nРелетата са сървъри, съхраняващи и доставящи вашите криптирани бележки. Можете да избирате релетата в **Настройки → Предпочитания → Свързани релета**. Използването на няколко релета повишава надеждността: ако едно е недостъпно, данните ще останат на другите.\n\n\n## Как работи\n\n1. **Създавате** бележка в редактора\n2. Бележката **се криптира** на устройството с помощта на NIP-44 и вашите nsec/ПИН\n3. Криптираната бележка **се подписва** и **се публикува** в избраните релета\n4. При отваряне на приложението бележките **се изтеглят** от релетата и **се декриптират** локално\n\nНикой – нито операторите на релетата, нито ние – не може да прочете вашите бележки. Само вие, разполагайки с nsec и ПИН, можете да ги декриптирате.\n\n\n## Препоръки\n\n- **Направете резервно копие на nsec** на безопасно място (например в мениджър на пароли). Без него акаунтът не може да бъде възстановен.\n- **Помнете вашия ПИН.** Той никъде не се съхранява и не може да бъде нулиран.\n- **Използвайте няколко релета** за по-добра достъпност и резервираност.\n- Вашият nsec работи във всички Nostr приложения – можете да използвате една и съща самоличност навсякъде.';

  @override
  String get notesListScreenTitle => 'Бележки';

  @override
  String get notesListTabAll => 'Всички';

  @override
  String get notesListTabFolders => 'Папки';

  @override
  String get notesListSearchHint => 'Търсене в бележките';

  @override
  String get notesListSearchNothingFound => 'Нищо не е намерено';

  @override
  String get notesListNewNoteTooltip => 'Нова бележка';

  @override
  String get notesFoldersEmptyStatePlaceholder =>
      'Присвоявайте етикети на бележките, за да ги групирате в папки';

  @override
  String get homeScreenEmptyStatePlaceholder =>
      'Натиснете +, за да създадете бележка';

  @override
  String get notesListSectionToday => 'Днес';

  @override
  String get notesListSectionPrevious7Days => 'Последните 7 дни';

  @override
  String get notesListSectionPrevious30Days => 'Последните 30 дни';

  @override
  String get notesListSectionOther => 'Друго';

  @override
  String get notesListConfirmationDialogDeletion =>
      'Сигурни ли сте, че искате да изтриете тази бележка? Действието не може да бъде отменено.';

  @override
  String get notesListAssignFolder => 'Папка';

  @override
  String get privacyPolicyScreenTitle => 'Политика за поверителност';

  @override
  String get classificationClassFinance => 'Финанси';

  @override
  String get classificationClassJournal => 'Дневник';

  @override
  String get classificationClassPersonal => 'Лично';

  @override
  String get classificationClassSecurity => 'Сигурност';

  @override
  String get classificationClassTravel => 'Пътувания';

  @override
  String get classificationClassWork => 'Работа';

  @override
  String get classificationClassBookmarks => 'Отметки';

  @override
  String get classificationClassOther => 'Друго';

  @override
  String get notePreviewMoreMenuAssignFolder => 'Присвои папка';

  @override
  String get notePreviewMoreMenuCopyContent => 'Копирай съдържанието';

  @override
  String get notePreviewMoreMenuInfo => 'Информация';

  @override
  String get notePreviewMoreMenuExportNote => 'Експортирай бележка';

  @override
  String get donateLightningScreenTitle => 'Поддръжка чрез Lightning ⚡';

  @override
  String get donateLightningScreenSubtitle =>
      'Подкрепете разработката с Lightning плащане';

  @override
  String get donateLightningScreenErrorInvoice =>
      'Неуспешно създаване на фактура';

  @override
  String get donateLightningScreenInputHint => 'Сума (сат)';

  @override
  String get donateLightningScreenWalletSectionTitle => 'Отвори в портфейл';

  @override
  String donateLightningScreenSubmitButtonOpenInWallet(String walletName) {
    return 'Отвори в $walletName';
  }

  @override
  String get donateLightningScreenSubmitButtonGenerateInvoice =>
      'Генерирай фактура';

  @override
  String get donateLightningScreenButtonEditAmount => 'Промени сумата';

  @override
  String get donateLightningScreenButtonCopyInvoice => 'Копирай фактурата';

  @override
  String get donateLightningScreenButtonOpenWithLightning =>
      'Отвори чрез Lightning';

  @override
  String get donateLightningScreenQrInstruction =>
      'Сканирайте QR кода с вашия Lightning портфейл на телефона.';

  @override
  String get donateLightningScreenMessageInvoiceCopied =>
      'Фактурата е копирана в клипборда';
}
