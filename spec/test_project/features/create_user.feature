Feature: Create User
  As an Administrator
  I want to create a new User
  So that he will love me

Scenario: New User
  Given I go to the Admin page
  And I create a new User
  Then I should see the new User's details
