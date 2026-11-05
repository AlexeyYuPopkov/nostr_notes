Feature: Authorized area tabs

  Background:
    Given the user is signed in
    And a chat with {'alice-pubkey'}

  Scenario: The chats tab opens first and lists the chats
    When I open the authorized area
    Then I see {'alice-pubkey'} text

  Scenario: The settings tab shows the settings screen
    When I open the authorized area
    And I tap semantics {'AuthTabs.settings'}
    Then I see semantics {'SettingsScreen.profileItem'}

  Scenario: Tapping a chat opens it
    When I open the authorized area
    And I tap {'alice-pubkey'} text
    Then I see semantics {'ChatScreen.messageField'}

  Scenario: A sent message appears in the chat
    When I open the authorized area
    And I tap {'alice-pubkey'} text
    And Input {'Hello'} at first tf
    And I tap semantics {'ChatScreen.sendButton'}
    Then I see {'Hello'} text
