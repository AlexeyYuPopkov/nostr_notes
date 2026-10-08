Feature: Save the generated key to a file

  Background:
    Given a fresh install
    And fake file dialogs
    And I open the onboarding screen
    And I tap {'Get Started'} text
    And I tap {'Generate a Nostr Key'} text

  @wip
  Scenario: The generated key can be saved to a file
    Then I see {'Save to File'} text

  @wip
  Scenario: The backup password must be at least 4 characters
    When I tap {'Save to File'} text
    And I enter {'123'} into backup password field
    And I tap {'OK'} text
    Then I see {'Password must be at least 4 characters'} text
    And no file was shared

  @wip
  Scenario: Cancelling the password dialog shares nothing
    When I tap {'Save to File'} text
    And I tap {'Cancel'} text
    Then no file was shared
    And I see {'Your Nostr Private Key (Nsec Key)'} page

  @wip
  Scenario: A valid password shares an encrypted backup and continues onboarding
    When I tap {'Save to File'} text
    And I enter {'1234'} into backup password field
    And I tap {'OK'} text
    Then a key backup zip was shared
    And I see {'Select Relays'} page
