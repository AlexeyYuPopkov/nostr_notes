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

  Scenario: A contact's new profile reaches the list
    Given {'Alice'} wrote me {'Hi there'}
    When I open the authorized area
    And the chat with {'Alice'} shows {'Hi there'}
    And {'Alice'} is now known as {'Alicia'}
    Then the chat with {'Alicia'} shows {'Hi there'}

  Scenario: A name the contact publishes reaches the open list
    Given {'Alice'} wrote me {'Hi there'}
    When I open the authorized area
    And the chat with {'Alice'} shows {'Hi there'}
    And {'Alice'} publishes the name {'Alicia'}
    Then the chat with {'Alicia'} shows {'Hi there'}

  Scenario: Each conversation keeps its contact when the list reorders
    Given {'Alice'} wrote me {'Hi there'} {2} hours ago
    And {'Bob'} wrote me {'Hello'} {1} hours ago
    When I open the authorized area
    And the chat with {'Bob'} shows {'Hello'}
    And {'Alice'} wrote me {'Back again'}
    Then the chat with {'Alice'} shows {'Back again'}
    And the chat with {'Bob'} shows {'Hello'}
