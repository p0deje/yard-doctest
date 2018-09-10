## 0.1.13

* Ignore files excluded in .yardopts (#7)

## 0.1.12

* Reworked the construction of context where examples are evaluated.

## 0.1.11

* Remove constants defined during test execution for better isolation.

## 0.1.10

* Properly share local context between assertions when scoped to class (#6)

## 0.1.9

* Allow to have `doctest_helper.rb` in `spec/` directory [#4](https://github.com/p0deje/yard-doctest/pull/4)
* Allow to use local context in doctest (i.e. not type full path to object) [#5](https://github.com/p0deje/yard-doctest/pull/5)

## 0.1.8

* Fixed a bug when test was passing even though exception was raised in example

## 0.1.7

* Fix a bug when only one of global and test-name hooks is executed for matching test

## 0.1.6

* Support per-example hooks [#3](https://github.com/p0deje/yard-doctest/pull/3)

## 0.1.5

* Support testing for exceptions [#2](https://github.com/p0deje/yard-doctest/pull/2)

## 0.1.4

* Allow to keep doctest_helper in support/ directory

## 0.1.3

* Rake task exits with non-zero code when doctests fail

## 0.1.2

* Allow skipping tests
* Allow configuring yard-doctest
* Rename helper from yard-doctest_helper to doctest_helper

## 0.1.1

* Refactoring

## 0.1.0

* Initial version
