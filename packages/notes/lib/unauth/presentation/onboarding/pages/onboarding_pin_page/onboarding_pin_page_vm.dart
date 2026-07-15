part of 'onboarding_pin_page.dart';

final class _VM extends ChangeNotifier with PinValidator {
  static const _autoUnlockDelay = Duration(seconds: 2);

  final _formKey = GlobalKey<FormState>(
    debugLabel: 'OnboardingPinPage.FormKey',
  );

  final _doneButtonKey = GlobalKey(debugLabel: 'OnboardingPinPage.DoneButton');

  final _controller = TextEditingController();

  final _keyboardVisible = ValueNotifier<bool>(false);

  final _autoUnlockCancelled = ValueNotifier<bool>(false);

  Timer? _autoUnlockTimer;
  bool _disposed = false;

  @override
  PinUsecase getPinUsecase(BuildContext context) =>
      context.read<OnboardingScreenBloc>().pinUsecase;

  /// Starts the auto-unlock countdown for a no-PIN account. No-op if the
  /// account still needs a PIN, the user already cancelled, or a timer is
  /// already running.
  void maybeStartAutoUnlock(OnboardingScreenBloc bloc) {
    if (!bloc.state.data.autoUnlock) return;
    if (_autoUnlockCancelled.value || _autoUnlockTimer != null) return;
    _autoUnlockTimer = Timer(_autoUnlockDelay, () {
      if (_disposed) return;
      unlockWithoutPin(bloc, null);
    });
  }

  /// Halts the countdown and reveals the manual unlock button.
  void cancelAutoUnlock() {
    _autoUnlockTimer?.cancel();
    _autoUnlockTimer = null;
    _autoUnlockCancelled.value = true;
  }

  /// Clears any pending countdown and the cancelled flag (e.g. when the
  /// pending account changes).
  void resetAutoUnlock() {
    _autoUnlockTimer?.cancel();
    _autoUnlockTimer = null;
    _autoUnlockCancelled.value = false;
  }

  /// Called when the account being authenticated changes (via the switcher):
  /// drop any typed PIN and reset the auto-unlock state for the new account.
  void onPendingAccountChanged() {
    resetAutoUnlock();
    _controller.clear();
    _formKey.currentState?.reset();
  }

  List<String> accounts() =>
      DiStorage.shared.resolve<AccountsRepo>().getAccounts();

  Future<void> switchAccount(BuildContext context, String pubkey) async {
    final authUsecase = context.read<OnboardingScreenBloc>().authUsecase;
    if (pubkey == authUsecase.currentSession.pubkey) return;
    try {
      await authUsecase.switchAccount(pubkey: pubkey);
    } catch (_) {
      // A stale account with no stored key is dropped by switchAccount; the
      // header rebuilds from the refreshed accounts list.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _autoUnlockTimer?.cancel();
    _controller.dispose();
    _keyboardVisible.dispose();
    _autoUnlockCancelled.dispose();
    super.dispose();
  }

  void onCheckboxChanged(
    BuildContext context,
    FormFieldState<bool> field,
    bool? value,
  ) {
    _formKey.currentState?.reset();
    field.didChange(value);
    final bloc = context.read<OnboardingScreenBloc>();
    bloc.add(OnboardingScreenEvent.didChangeSettings(value ?? true));
  }

  void onNext(BuildContext context, LoadingButtonVM? vm) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      final bloc = context.read<OnboardingScreenBloc>();
      final isUsePin = bloc.state.data.isUsePin;
      bloc.add(
        OnboardingScreenEvent.onPin(
          pin: _controller.text,
          vm: vm,
          usePin: isUsePin,
        ),
      );
    }
  }

  void unlockWithoutPin(OnboardingScreenBloc bloc, LoadingButtonVM? vm) {
    bloc.add(OnboardingScreenEvent.onPin(pin: '', vm: vm, usePin: false));
  }
}