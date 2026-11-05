Feature: Authorized area tabs

  Background:
    Given the user is signed in

  After:
    Then I close the app

  Scenario: The chats tab opens first
    When I open the authorized area
    Then I see {'No chats yet'} text

  Scenario: The settings tab shows the settings screen
    When I open the authorized area
    And I tap semantics {'AuthTabs.settings'}
    Then I see semantics {'SettingsScreen.profileItem'}
