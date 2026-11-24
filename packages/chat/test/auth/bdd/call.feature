Feature: Calls from a chat

  Background:
    Given the user is signed in
    And {'Alice'} wrote me {'Hi there'}
    And calls never connect

  After:
    Then I close the app

  Scenario: An audio call rings the contact
    When I open the chat with {'Alice'}
    And I tap semantics {'ChatScreen.audioCall'}
    Then I am calling {'Alice'} with {'audio'}
    And I see {'Calling…'} text

  Scenario: A video call rings the contact
    When I open the chat with {'Alice'}
    And I tap semantics {'ChatScreen.videoCall'}
    Then I am calling {'Alice'} with {'video'}

  Scenario: Hanging up returns to the chat
    When I open the chat with {'Alice'}
    And I tap semantics {'ChatScreen.audioCall'}
    And I tap semantics {'call_view.hang_up'}
    Then the call screen is closed
    And the conversation shows {'Hi there'}
