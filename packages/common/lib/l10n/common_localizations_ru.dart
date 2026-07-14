// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'common_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class CommonLocalizationsRu extends CommonLocalizations {
  CommonLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get commonButtonBack => 'Назад';

  @override
  String get commonButtonOk => 'OK';

  @override
  String get commonButtonCancel => 'Отмена';

  @override
  String get commonButtonContinue => 'Продолжить';

  @override
  String get commonButtonNext => 'Далее';

  @override
  String get commonButtonSave => 'Сохранить';

  @override
  String get commonButtonDone => 'Готово';

  @override
  String get commonButtonEdit => 'Изменить';

  @override
  String get commonHintSearch => 'Поиск...';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonError => 'Ошибка';

  @override
  String get commonAttention => 'Внимание';

  @override
  String get commonUndefinedError => 'Что-то пошло не так';

  @override
  String get commonNoDataPlaceholderText => 'Данных нет';

  @override
  String get commonCopied => 'Скопировано';

  @override
  String get commonInfo => 'Информация';

  @override
  String get commonWarning => 'Предупреждение';

  @override
  String get authError => 'Ошибка аутентификации';

  @override
  String get themeScreenTitle => 'Тема';

  @override
  String get themeScreenSectionTitleColorTheme => 'Цветовая тема';

  @override
  String get themeScreenLabelSystem => 'Системная';

  @override
  String get themeScreenLabelLight => 'Светлая';

  @override
  String get themeScreenLabelDark => 'Темная';

  @override
  String get themeScreenLabelBackground => 'Фон';

  @override
  String get themeScreenLabelCards => 'Карточки';

  @override
  String get relaysPageTitle => 'Выбор реле';

  @override
  String get relaysPageDescription =>
      'Реле - это серверы, которые хранят и доставляют ваши зашифрованные заметки. Выберите хотя бы одно реле, чтобы продолжить';

  @override
  String get relaysPageAddCustomLabel =>
      'Опционально добавьте своё реле, указав его адрес';

  @override
  String get relaysPageAddCustomHint => 'wss://...';

  @override
  String get relaysPageAddButton => 'Добавить';

  @override
  String get relaysPageCheckButton => 'Проверить';

  @override
  String get relaysPageErrorSelectAtLeastOne => 'Выберите хотя бы одно реле';

  @override
  String get relaysPageErrorInvalidRelayUrlEmpty => 'URL не может быть пустым';

  @override
  String get relaysPageErrorInvalidUrl =>
      'URL должен начинаться с wss:// или ws://';

  @override
  String get relaysPageErrorInvalidRelayAddressFormat =>
      'Неверный формат адреса реле';

  @override
  String relaysPageErrorFailedToConnectToRelay(String url) {
    return 'Не удалось подключиться к реле $url';
  }

  @override
  String get rawEventScreenTitle => 'Сырой event';

  @override
  String rawEventScreenSectionTitleRelaysCount(String count) {
    return 'Реле ($count)';
  }

  @override
  String get rawEventScreenSectionTitleJson => 'JSON';

  @override
  String get commonLinkCopyLink => 'Копировать ссылку';

  @override
  String get commonLinkOpenInBrowser => 'Открыть в браузере';

  @override
  String get commonLinkOpenInNewTab => 'Открыть в новой вкладке';

  @override
  String get commonLinkOpenInExternalBrowser => 'Открыть во внешнем браузере';
}
