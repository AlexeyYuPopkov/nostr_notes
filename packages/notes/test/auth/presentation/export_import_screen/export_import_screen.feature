Feature: Export import screen

  Background:
    Given a fresh install
    And Export import screen visible

  Scenario: Export the current account's key to an encrypted file
    Given fake file dialogs
    When I see {'Keys'} text
    And I tap semantics {'ExportImportScreen.exportKeyItem'}
    And I enter {'1234'} into backup password field
    And I tap {'OK'} text
    And the key file is prepared
    Then a key backup zip was shared
    And I see {'Key file saved'} text
