import 'package:flutter/material.dart';

typedef SearchVMMatch = ({int start, int end});

List<SearchVMMatch> _findMatches(String text, String query) {
  if (query.isEmpty) return const [];
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final matches = <SearchVMMatch>[];
  int start = 0;
  while (true) {
    final idx = lowerText.indexOf(lowerQuery, start);
    if (idx == -1) break;
    matches.add((start: idx, end: idx + query.length));
    start = idx + query.length;
  }
  return matches;
}

final class SearchVM extends ChangeNotifier {
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  final isSearchVisible = ValueNotifier(false);
  final searchQuery = ValueNotifier('');
  final currentMatchIndex = ValueNotifier(0);

  bool get isVisible => isSearchVisible.value;
  bool get isSearchEmpty => searchQuery.value.isEmpty;
  bool get isSearchNotEmpty => searchQuery.value.isNotEmpty;

  late final Listenable searchStateListenable = Listenable.merge([
    isSearchVisible,
    searchQuery,
    currentMatchIndex,
  ]);

  SearchVM() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      currentMatchIndex.value = 0;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    isSearchVisible.dispose();
    searchQuery.dispose();
    currentMatchIndex.dispose();
    super.dispose();
  }

  void toggleSearch() {
    final newValue = !isSearchVisible.value;
    isSearchVisible.value = newValue;
    if (!newValue) {
      searchController.clear();
      searchQuery.value = '';
      currentMatchIndex.value = 0;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentMatchIndex.value = 0;
  }

  void nextMatch(String content, int matchCount) {
    if (matchCount == 0) {
      return;
    }
    final next = (currentMatchIndex.value + 1) % matchCount;
    currentMatchIndex.value = next;

    _scrollToMatch(content, next);
  }

  void prevMatch(String content, int matchCount) {
    if (matchCount == 0) {
      return;
    }
    final prev = (currentMatchIndex.value - 1 + matchCount) % matchCount;
    currentMatchIndex.value = prev;
    _scrollToMatch(content, prev);
  }

  void _scrollToMatch(String content, int index) {
    if (content.isEmpty) {
      return;
    }
    final matches = _findMatches(content, searchQuery.value);
    if (index >= matches.length) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }
      final maxScroll = scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
        return;
      }
      final ratio = matches[index].start / content.length;
      scrollController.animateTo(
        (ratio * maxScroll).clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  List<({int end, int start})> getMatches(String content) {
    final matches = isSearchVisible.value && searchQuery.value.isNotEmpty
        ? _findMatches(content, searchQuery.value)
        : const <SearchVMMatch>[];
    return matches;
  }
}
