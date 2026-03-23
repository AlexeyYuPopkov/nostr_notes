#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim
  make -f /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim
  make -f /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim
  make -f /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim
  make -f /Users/alekseypopkov/Doc/nostr_notes/nostr_notes/cpp/ffi/build-ios-sim/CMakeScripts/ReRunCMake.make
fi

