Feature: Sign in with a key backup file

  Background:
    Given a fresh install
    And the app was launched before
    And fake file dialogs

  @wip
  Scenario: The sign-in page offers loading the key from a file
    When I open the onboarding screen
    And I tap {'Get Started'} text
    Then I see {'Load from File'} text

  @wip
  Scenario: A key file with the correct password signs in
    Given a key backup file protected with {'1234'}
    When I open the onboarding screen
    And I tap {'Get Started'} text
    And I tap {'Load from File'} text
    And I enter {'1234'} into backup password field
    And I tap {'OK'} text
    Then I see {'Select Relays'} page

  @wip
  Scenario: A wrong password keeps the user on the sign-in page
    Given a key backup file protected with {'1234'}
    When I open the onboarding screen
    And I tap {'Get Started'} text
    And I tap {'Load from File'} text
    And I enter {'9999'} into backup password field
    And I tap {'OK'} text
    Then I see {'Wrong password, or the backup is corrupted.'} text
    And I see {'Enter your Nostr nsec'} page

  @wip
  Scenario: A notes backup is not accepted as a key file
    Given a notes backup file
    When I open the onboarding screen
    And I tap {'Get Started'} text
    And I tap {'Load from File'} text
    And I enter {'1234'} into backup password field
    And I tap {'OK'} text
    Then I see {'This file is not a key backup.'} text
    And I see {'Enter your Nostr nsec'} page

  @wip
  Scenario: Cancelling the file picker keeps the sign-in page
    Given the file picker is cancelled
    When I open the onboarding screen
    And I tap {'Get Started'} text
    And I tap {'Load from File'} text
    Then I see {'Enter your Nostr nsec'} page
