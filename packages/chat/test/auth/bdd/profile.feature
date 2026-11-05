Feature: Edit my profile

  Background:
    Given the user is signed in
    And my profile is named {'Alice'}

  Scenario: The profile opens from the settings
    When I open the authorized area
    And I tap semantics {'AuthTabs.settings'}
    And I tap semantics {'SettingsScreen.profileItem'}
    Then I see {'Alice'} text

  Scenario: A malformed picture link is rejected
    When I open my profile
    And I enter {'not a link'} into semantics {'ProfileScreen.pictureField'}
    Then I see {'Enter a full link starting with https:// or http://'} text

  Scenario: A saved name is kept
    When I open my profile
    And I enter {'Bob'} into semantics {'ProfileScreen.nameField'}
    And I tap semantics {'ProfileScreen.saveButton'}
    Then I see {'Profile saved'} text
    And my saved name is {'Bob'}

  Scenario: A profile no relay accepted stays on the device
    Given no relay accepts my profile
    When I open my profile
    And I enter {'Bob'} into semantics {'ProfileScreen.nameField'}
    And I tap semantics {'ProfileScreen.saveButton'}
    Then I see {'Saved on this device, but no relay accepted it'} text
    And my saved name is {'Bob'}

  Scenario: My public keys are shown
    When I open my profile
    Then I see {'npub1sg6plzptd64u62a878hep2kev88swjh3tw00gjsfl8f237lmu63q0uf63m'} text
    And I see {'82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2'} text

  Scenario: The npub can be copied
    Given a fake clipboard
    When I open my profile
    And I tap semantics {'ProfileScreen.npubCopyButton'}
    Then the clipboard contains {'npub1sg6plzptd64u62a878hep2kev88swjh3tw00gjsfl8f237lmu63q0uf63m'}

  Scenario: The hex public key can be copied
    Given a fake clipboard
    When I open my profile
    And I tap semantics {'ProfileScreen.pubkeyCopyButton'}
    Then the clipboard contains {'82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2'}
