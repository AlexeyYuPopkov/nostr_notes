// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'common_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class CommonLocalizationsBg extends CommonLocalizations {
  CommonLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get commonButtonBack => 'Назад';

  @override
  String get commonButtonOk => 'OK';

  @override
  String get commonButtonCancel => 'Отказ';

  @override
  String get commonButtonContinue => 'Продължи';

  @override
  String get commonButtonNext => 'Напред';

  @override
  String get commonButtonSave => 'Запази';

  @override
  String get commonButtonDone => 'Готово';

  @override
  String get commonButtonEdit => 'Редактирай';

  @override
  String get commonHintSearch => 'Търсене...';

  @override
  String get commonClose => 'Затвори';

  @override
  String get commonDelete => 'Изтрий';

  @override
  String get commonError => 'Грешка';

  @override
  String get commonAttention => 'Внимание';

  @override
  String get commonUndefinedError => 'Нещо се обърка';

  @override
  String get commonNoDataPlaceholderText => 'Не са намерени данни';

  @override
  String get commonCopied => 'Копирано';

  @override
  String get commonInfo => 'Информация';

  @override
  String get commonWarning => 'Предупреждение';

  @override
  String get authError => 'Грешка при удостоверяване';

  @override
  String get themeScreenTitle => 'Тема';

  @override
  String get themeScreenSectionTitleColorTheme => 'Цветова тема';

  @override
  String get themeScreenLabelSystem => 'Системна';

  @override
  String get themeScreenLabelLight => 'Светла';

  @override
  String get themeScreenLabelDark => 'Тъмна';

  @override
  String get themeScreenLabelBackground => 'Фон';

  @override
  String get themeScreenLabelCards => 'Карти';

  @override
  String get themeScreenLabelStyle => 'Стил';

  @override
  String get themeScreenStyleDefault => 'Стандартна';

  @override
  String get themeScreenStyleAppleNotes => 'Apple Notes';

  @override
  String get themeScreenStyleClaude => 'Claude';

  @override
  String get relaysPageTitle => 'Избери релета';

  @override
  String get relaysPageDescription =>
      'Релетата са сървъри, които съхраняват и доставят вашите криптирани бележки. Изберете поне едно реле, за да продължите';

  @override
  String get relaysPageAddCustomLabel =>
      'По желание добавете свое реле, като въведете неговия адрес';

  @override
  String get relaysPageAddCustomHint => 'wss://...';

  @override
  String get relaysPageAddButton => 'Добави';

  @override
  String get relaysPageCheckButton => 'Провери';

  @override
  String get relaysPageErrorSelectAtLeastOne => 'Изберете поне едно реле';

  @override
  String get relaysPageErrorInvalidRelayUrlEmpty =>
      'URL не може да бъде празен';

  @override
  String get relaysPageErrorInvalidUrl =>
      'URL трябва да започва с wss:// или ws://';

  @override
  String get relaysPageErrorInvalidRelayAddressFormat =>
      'Невалиден формат на адреса на реле';

  @override
  String relaysPageErrorFailedToConnectToRelay(String url) {
    return 'Неуспешно свързване с реле $url';
  }

  @override
  String get rawEventScreenTitle => 'Суров event';

  @override
  String rawEventScreenSectionTitleRelaysCount(String count) {
    return 'Релета ($count)';
  }

  @override
  String get rawEventScreenSectionTitleJson => 'JSON';

  @override
  String get commonLinkCopyLink => 'Копирай линк';

  @override
  String get commonLinkOpenInBrowser => 'Отвори в браузъра';

  @override
  String get commonLinkOpenInNewTab => 'Отвори в нов раздел';

  @override
  String get commonLinkOpenInExternalBrowser => 'Отвори във външен браузър';
}
