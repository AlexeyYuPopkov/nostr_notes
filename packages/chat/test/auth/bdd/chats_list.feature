Feature: Chats list

  Background:
    Given the user is signed in

  After:
    Then I close the app

  Scenario: Without chats the list offers to start one
    When I open the authorized area
    And I tap semantics {'ChatsListScreen.startChatButton'}
    Then I see semantics {'SearchContactScreen.searchField'}

  Scenario: A conversation shows the contact's name and the last message
    Given {'Alice'} wrote me {'Hi there'}
    When I open the authorized area
    Then the chat with {'Alice'} shows {'Hi there'}

  Scenario: Tapping a conversation opens it
    Given {'Alice'} wrote me {'Hi there'}
    When I open the chat with {'Alice'}
    Then I see semantics {'ChatScreen.sendButton'}
