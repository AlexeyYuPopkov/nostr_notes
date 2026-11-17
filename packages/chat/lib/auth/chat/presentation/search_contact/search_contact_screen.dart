import 'dart:async';

import 'package:chat/auth/chat/presentation/search_contact/provider/search_contact_data.dart';
import 'package:chat/auth/chat/presentation/search_contact/provider/search_contact_provider.dart';
import 'package:chat/auth/chat/presentation/search_contact/provider/search_contact_state.dart';
import 'package:chat/auth/chat/presentation/search_contact/widgets/contact_list_cell.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class SearchContactScreenCoordinator {
  Future<void> onChatRoute(BuildContext context, {required String pubkey});
}

final class SearchContactScreen extends ConsumerWidget {
  static const searchFieldSemanticsId = 'SearchContactScreen.searchField';
  static const closeButtonSemanticsId = 'SearchContactScreen.closeButton';

  final SearchContactScreenCoordinator coordinator;

  const SearchContactScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(searchContactProviderProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          identifier: closeButtonSemanticsId,
          child: const CloseButton(),
        ),
        title: Text(context.l10n.searchContactTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Sizes.indent2x),
              child: Semantics(
                identifier: searchFieldSemanticsId,
                child: TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.l10n.searchContactHint,
                  ),
                  onChanged: provider.onQueryChanged,
                ),
              ),
            ),
            Expanded(child: _SearchResults(coordinator: coordinator)),
          ],
        ),
      ),
    );
  }
}

final class _SearchResults extends ConsumerWidget {
  final SearchContactScreenCoordinator coordinator;

  const _SearchResults({required this.coordinator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchContactProviderProvider);
    final data = state.data;

    return switch (state) {
      SearchContactLoading() => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      SearchContactError() when data.users.isEmpty => _Message(
        context.l10n.searchContactError,
      ),
      SearchContactError() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Sizes.indent),
            child: Text(
              context.l10n.searchContactError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          Expanded(
            child: _UsersList(data: data, coordinator: coordinator),
          ),
        ],
      ),
      SearchContactCommon() when !data.hasQuery => _Message(
        context.l10n.searchContactInitialHint,
      ),
      SearchContactCommon() when data.users.isEmpty => _Message(
        context.l10n.searchContactNoResults,
      ),
      SearchContactCommon() => _UsersList(data: data, coordinator: coordinator),
    };
  }
}

final class _UsersList extends StatelessWidget {
  final SearchContactData data;
  final SearchContactScreenCoordinator coordinator;

  const _UsersList({required this.data, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: data.users.length,
      separatorBuilder: (_, _) => const SizedBox(height: Sizes.indent),
      itemBuilder: (context, index) {
        final user = data.users[index];
        return ContactListCell(
          user: user,
          onTap: () =>
              unawaited(coordinator.onChatRoute(context, pubkey: user.pubkey)),
        );
      },
    );
  }
}

final class _Message extends StatelessWidget {
  final String text;

  const _Message(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.indent2x),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
