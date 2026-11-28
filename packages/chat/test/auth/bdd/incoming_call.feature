Feature: Incoming calls

  Background:
    Given the user is signed in
    And {'Alice'} wrote me {'Hi there'}
    And calls never connect

  After:
    Then I close the app

  Scenario: A fresh invite rings
    Given {'Alice'} invited me to a call {'video'}
    When I open the authorized area
    Then the incoming call from {'Alice'} rings
    And I see {'Incoming video call'} text

  Scenario: An invite the caller gave up on does not ring
    Given {'Alice'} invited me to a call {'video'} {2} minutes ago
    When I open the chat with {'Alice'}
    Then the conversation shows {'Video call'}
    And I don't see {'Incoming video call'} text

  Scenario: Accepting joins the call
    Given {'Alice'} invited me to a call {'audio'}
    When I open the authorized area
    And the incoming call from {'Alice'} rings
    And I tap semantics {'IncomingCallScreen.accept'}
    Then I see {'Connecting…'} text

  Scenario: Declining stops the ringing
    Given {'Alice'} invited me to a call {'audio'}
    When I open the authorized area
    And the incoming call from {'Alice'} rings
    And I tap semantics {'IncomingCallScreen.decline'}
    Then I don't see {'Incoming audio call'} text
    And the chat with {'Alice'} shows {'Audio call'}

  Scenario: Declining tells the caller
    Given {'Alice'} invited me to a call {'video'}
    When I open the authorized area
    And the incoming call from {'Alice'} rings
    And I tap semantics {'IncomingCallScreen.decline'}
    Then {'Alice'} is told the call was {'declined'}

  Scenario: A call the caller cancels stops ringing
    Given {'Alice'} invited me to a call {'video'}
    When I open the authorized area
    And the incoming call from {'Alice'} rings
    And {'Alice'} cancelled the call
    Then the incoming call stops ringing
    And the chat with {'Alice'} shows {'Call cancelled'}
