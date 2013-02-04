Feature: move

  So that I can keep items organised
  As a user
  I want to move items between files

  Background:
    Given a config exists with the following files:
      | alias    | path         |
      | todo     | todo.txt     | 
      | wishlist | wishlist.txt | 
    And a todofile with the following items exists:
      | todo                               |
      | Getting Things Done @bookstore     |
      | Label Maker @officesupply          |
    And an empty todofile named "wishlist.txt" exists

  Scenario: Move item from todo.txt to wishlist.txt
    When I run `todotxt move 1 wishlist`
    Then it should pass with:
      """
      1. Getting Things Done @bookstore
      => Moved to wishlist.txt
      """
    And the file "todo.txt" should not contain "Getting Things Done @bookstore"
    And the file "wishlist.txt" should contain "Getting Things Done @bookstore"

  Scenario: Move an illegal item
    When I run `todotxt move 1337 wishlist`
    Then it should pass with:
      """
      ERROR: No todo found at line 1337
      """
