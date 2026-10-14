Feature: Onboarding welcome page

  Background:
    Given a fresh install

  Scenario: A new user sees the welcome page
    When I open the onboarding screen
    Then I see {'Get Started'} text
    And I see {'Help'} text

  Scenario: Get Started offers sign up on the first launch
    When I open the onboarding screen
    And I tap {'Get Started'} text
    Then I see {'Sign Up with Nostr'} page

  Scenario: Get Started offers sign in once the app was launched before
    Given the app was launched before
    When I open the onboarding screen
    And I tap {'Get Started'} text
    Then I see {'Enter your Nostr nsec'} page
