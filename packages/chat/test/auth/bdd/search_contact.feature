Feature: Search for a contact to chat with

  Background:
    Given the user is signed in
    And a contact named {'Alice'} can be found

  After:
    Then I close the app

  Scenario: The search opens from the chats list
    When I open the authorized area
    And I tap semantics {'ChatsListScreen.searchContactButton'}
    Then I see {'Search people by name, npub or public key'} text

  Scenario: A matching contact is listed with its name
    When I open the authorized area
    And I tap semantics {'ChatsListScreen.searchContactButton'}
    And I search for {'ali'}
    Then I see {'Alice'} text

  Scenario: Nothing matches
    When I open the authorized area
    And I tap semantics {'ChatsListScreen.searchContactButton'}
    And I search for {'zzz'}
    Then I see {'No users found'} text

  Scenario: Tapping a contact replaces the search with the chat
    When I open the authorized area
    And I tap semantics {'ChatsListScreen.searchContactButton'}
    And I search for {'ali'}
    And I tap {'Alice'} text
    Then I see semantics {'ChatScreen.sendButton'}
    And I don't see {'New chat'} text

  Scenario: Closing the search returns to the chats list
    When I open the authorized area
    And I tap semantics {'ChatsListScreen.searchContactButton'}
    And I tap semantics {'SearchContactScreen.closeButton'}
    Then I see semantics {'ChatsListScreen.searchContactButton'}
    And I don't see {'New chat'} text
