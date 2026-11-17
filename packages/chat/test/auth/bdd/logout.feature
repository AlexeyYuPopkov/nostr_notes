Feature: Sign out

  Background:
    Given the user is signed in
    And my key is saved on this device

  After:
    Then I close the app

  Scenario: Signing out returns to the onboarding
    When I open the authorized area
    And I tap semantics {'AuthTabs.settings'}
    And I tap semantics {'SettingsScreen.logoutItem'}
    And I tap {'OK'} text
    Then I see {'Welcome to\nEncrypted Chat (Nostr)'} text
    And I am signed out

  Scenario: Cancelled sign out keeps the session
    When I open the authorized area
    And I tap semantics {'AuthTabs.settings'}
    And I tap semantics {'SettingsScreen.logoutItem'}
    And I tap {'Cancel'} text
    Then I see semantics {'SettingsScreen.logoutItem'}
    And I am still signed in
