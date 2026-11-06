Feature: One-to-one chat

  Background:
    Given the user is signed in
    And {'Alice'} wrote me {'Hi there'}

  After:
    Then I close the app

  Scenario: The conversation shows received messages
    When I open the chat with {'Alice'}
    Then the conversation shows {'Hi there'}

  Scenario: A sent message reaches the contact
    When I open the chat with {'Alice'}
    And I send {'Hello'}
    Then the conversation shows {'Hello'}
    And {'Alice'} receives {'Hello'}

  Scenario: A message that arrives while the chat is open is shown
    When I open the chat with {'Alice'}
    And {'Alice'} writes me {'Are you there?'}
    Then the conversation shows {'Are you there?'}

  Scenario: An edited message shows the new text
    When I open the chat with {'Alice'}
    And I send {'Helo'}
    And I long press {'Helo'} text
    And I tap semantics {'MessageActionsSheet.edit'}
    And I send {'Hello'}
    Then the conversation shows {'Hello'}
    And I see {'edited'} text
    And {'Alice'} receives {'Hello'}

  Scenario: The contact's message can be copied but not edited
    When I open the chat with {'Alice'}
    And I long press {'Hi there'} text
    Then I see semantics {'MessageActionsSheet.copy'}
    And I don't see {'Edit'} text
