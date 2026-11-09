Feature: Fortran functor execution

  Scenario: Execute a registered arithmetic functor
    Given the functor registry is initialized
    And the ADD functor is registered
    When I execute ADD with vector [2, 4, 6, 8]
    Then the execution status should be successful
    And the result should equal [6, 14]

  Scenario: Reject an invalid vector
    Given the functor registry is initialized
    And the ADD functor is registered
    When I execute ADD with vector [2, 4, 6]
    Then the execution status should be unsuccessful

  Scenario: Reject an unregistered functor
    Given the functor registry is initialized
    When I execute UNKNOWN
    Then the resolver should reject execution
```

`specifications/features/syntax_validation.feature`

```gherkin
