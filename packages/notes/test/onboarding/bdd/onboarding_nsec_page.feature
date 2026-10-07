Feature: Onboarding nsec page

  Background:
    Given a fresh install
    And the app was launched before

  Scenario: User Input wrong nsec
    When I open the onboarding screen
    And I tap text {'Get Started'}
    Then I see {'Enter your Nostr nsec'} text
    And Input {'garbage'} at first tf
    And I tap text {'Next'}
    Then Error {'Invalid NSEC key'} at first tf 


