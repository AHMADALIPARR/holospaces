Feature: Custom syntax validation

  Scenario: Parse a valid SKL module
    Given a valid SKL source module
    When the lexer generates tokens
    And the parser constructs an AST
    Then semantic analysis should succeed

  Scenario: Reject invalid syntax
    Given an SKL module with an invalid token
    When the parser processes the module
    Then a syntax error should be returned
    And execution should not begin

  Scenario: Reject an incompatible functor type
    Given a valid SKL syntax tree
    When a functor receives an incompatible input type
    Then semantic analysis should reject the program
```

### 6\. JUST orchestration

`justfile`

```make
set shell := ["bash", "-cu"]

FC := "gfortran"
FLAGS := "-std=f2018 -O2 -Wall -Wextra -fcheck=all"
