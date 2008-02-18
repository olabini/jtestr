Story: transfer from one hashmap to another hashmap
  As a programmer
  I want to transfer one object from one hashmap to another hashmap
  To check that it works correctly

  Scenario: object exists in original hashmap
    Given my hashmap contains "foo" with value "bar"
    And my other hashmap is empty
    When I transfer value with key "foo" from my hashmap to my other hashmap
    Then my other hashmap should contain "foo" with value "bar"
    And my hashmap should be empty

  Scenario: transferring an object back and forth
    Given my hashmap contains "foo" with value "bar"
    And my hashmap contains "baz" with value "foo"
    And my other hashmap is empty
    When I transfer value with key "foo" from my hashmap to my other hashmap
    And I transfer value with key "foo" from my other hashmap to my hashmap
    Then my hashmap should contain "foo" with value "bar"
    And my hashmap should contain "baz" with value "foo"
    And my other hashmap should be empty
