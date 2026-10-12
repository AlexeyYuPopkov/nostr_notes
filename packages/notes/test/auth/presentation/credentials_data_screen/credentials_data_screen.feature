Feature: Credentials data screen

  Background:
    Given a fresh install
    Given a fake clipboard
    And Credentials data screen visible

  Scenario: User Sees
    When I see {'Nsec'} text
    When I see semantics {'CredentialsDataScreen.nsec.visibilityButton'}
    And I dont see {'nsec165gu5pq9zakf8a2p9sfm97g4kaf66439crdjnl0592wd9en0588qcqrtzg'} text
    When I tap semantics {'CredentialsDataScreen.nsec.visibilityButton'}
    And I see text {'nsec165gu5pq9zakf8a2p9sfm97g4kaf66439crdjnl0592wd9en0588qcqrtzg'}
    When I tap semantics {'CredentialsDataScreen.nsec.copyButton'}
    Then the clipboard contains {'nsec165gu5pq9zakf8a2p9sfm97g4kaf66439crdjnl0592wd9en0588qcqrtzg'}

    When I see semantics {'CredentialsDataScreen.privateKey.visibilityButton'}
    And I dont see {'d511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce'} text
    When I tap semantics {'CredentialsDataScreen.privateKey.visibilityButton'}
    And I see text {'d511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce'}
    When I tap semantics {'CredentialsDataScreen.privateKey.copyButton'}
    Then the clipboard contains {'d511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce'}

    When I scroll to semantics {'CredentialsDataScreen.npub.copyButton'}
    And I see text {'npub133uf2gtfza75lwjx00h9gq5a5krhaa8lmtcsry465aqyf2g5m78s3wlua8'}
    When I tap semantics {'CredentialsDataScreen.npub.copyButton'}
    Then the clipboard contains {'npub133uf2gtfza75lwjx00h9gq5a5krhaa8lmtcsry465aqyf2g5m78s3wlua8'}

    When I scroll to semantics {'CredentialsDataScreen.pubKey.copyButton'}
    And I see text {'8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f'}
    When I tap semantics {'CredentialsDataScreen.pubKey.copyButton'}
    Then the clipboard contains {'8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f'}

    When I see semantics {'CredentialsDataScreen.pin.visibilityButton'}
    And I dont see {'270'} text
    When I tap semantics {'CredentialsDataScreen.pin.visibilityButton'}
    And I see text {'270'}
    When I tap semantics {'CredentialsDataScreen.pin.copyButton'}
    Then the clipboard contains {'270'}

  Scenario: Save the nsec to an encrypted key file
    Given fake file dialogs
    When I tap semantics {'CredentialsDataScreen.nsec.saveButton'}
    And I enter {'1234'} into backup password field
    And I tap {'OK'} text
    And the key file is prepared
    Then a key backup zip was shared
    And I see {'Key file saved'} text
