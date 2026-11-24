Feature: Relays list in the settings

  Background:
    Given the user is signed in

  After:
    Then I close the app

  Scenario: The relays list opens from the settings
    When I open the relays list
    Then I see {'ws://relay.test'} text

  Scenario: A deselected relay is saved
    When I open the relays list
    And I tap semantics {'RelayTile.checkbox.ws://relay.test'}
    And I tap {'Save'} text
    Then my saved relays are {''}
