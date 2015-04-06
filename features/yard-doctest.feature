Feature: yard doctest
  In order to avoid creating separated from code tests
  And to keep my code examples correct and meaningful
  As a developer
  I want to automatically parse YARD's @example tags
  And use them as tests
  Just like doctest in Python

  Scenario: adds new command to yard
    When I run `bundle exec yard --help`
    Then the output should contain "doctest  Doctests from @example tags"

  Scenario: looks for files in app/lib directories by default
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      require 'lib/lib'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 4
      def sum(one, two)
        one + two
      end
      """
    And a file named "lib/lib.rb" with:
      """
      # @example
      #   sub(2, 2) #=> 0
      def sub(one, two)
        one - two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "2 runs, 2 assertions, 0 failures, 0 errors, 0 skips"

  Scenario Outline: looks for files only in passed glob
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      require 'lib/lib'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 4
      def sum(one, two)
        one + two
      end
      """
    And a file named "lib/lib.rb" with:
      """
      # @example
      #   sub(2, 2) #=> 0
      def sub(one, two)
        one - two
      end
      """
    When I run `bundle exec yard doctest <glob>`
    Then the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"
    Examples:
      | glob        |
      | app         |
      | app/*.rb    |
      | app/**      |
      | app/**/*.rb |
      | app/app.rb  |

  Scenario: generates test names from unit name
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 4
      def sum(one, two)
        one + two
      end

      module A
        # @example
        #   sub(2, 2) #=> 0
        def sub(one, two)
          one - two
        end
      end

      class B
        # @example
        #   B.multiply(3, 3) #=> 9
        def self.multiply(one, two)
          one * two
        end

        # @example
        #   div(9, 3) #=> 3
        def div(one, two)
          one / two
        end
      end
      """
    When I run `bundle exec yard doctest -v`
    Then the output should contain "#sum"
    And the output should contain "A#sub"
    And the output should contain "B.multiply"
    And the output should contain "B#div"

  Scenario: asserts using equality
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(1, 1) #=> 2
      def sum(one, two)
        (one + two).to_s
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain:
      """
      Expected: 2
        Actual: "2"
      """

  Scenario Outline: properly handles different return values
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   foo #=> <value>
      def foo
        <value>
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"
    Examples:
      | value |
      | true  |
      | false |
      | nil   |
      | ''    |
      | ""    |
      | []    |
      | {}    |
      | Class |
      | 0     |
      | 10    |
      | -1    |
      | 1.0   |

  Scenario: handles multiple @example tags
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 4
      # @example
      #   sum(3, 3) #=> 6
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "2 runs, 2 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: handles multiple return comments
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   a = 1
      #   sum(a, 2) #=> 3
      #   sum(a, 3) #=> 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 2 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: runs @example tags without return comment
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2)
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 0 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: handles `# =>` return comment
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) # => 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: handles return comment on newline
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2)
      #   #=> 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: handles multiple lines
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   a = 1
      #   b = 2
      #   sum(a, b)
      #   #=> 3
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: names test with example title when it's present
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example sums two numbers
      #   sum(2, 2) #=> 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest -v`
    Then the output should contain "#sum#test_0001_sums two numbers"

  Scenario: doesn't name test when title is not present
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest -v`
    Then the output should contain "#sum#test_0001_"

  Scenario: adds unit definition to backtrace on failures
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 5
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "app/app.rb:3"

  Scenario: has rake task to run the tests
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 4
      def sum(one, two)
        one + two
      end
      """
    And a file named "Rakefile" with:
      """
      require 'yard-doctest'
      YARD::Doctest::RakeTask.new do |task|
        task.doctest_opts = %w[-v]
        task.pattern = 'app/**/*.rb'
      end
      """
    When I run `bundle exec rake yard:doctest`
    Then the exit status should be 0
    And the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: propagates exit code to rake task
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(2, 2) #=> 5
      def sum(one, two)
        one + two
      end
      """
    And a file named "Rakefile" with:
      """
      require 'yard-doctest'
      YARD::Doctest::RakeTask.new
      """
    When I run `bundle exec rake yard:doctest`
    Then the exit status should be 1

  Scenario Outline: requires doctest helper
    Given a file named "<directory>/doctest_helper.rb" with:
      """
      require 'app/app'

      def a
        2
      end

      def b
        2
      end
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   sum(a, b) #=> 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"
    Examples:
      | directory |
      | .         |
      | support   |

  Scenario: shares binding between asserts
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   a, b = 1, 2
      #   sum(a, b) #=> 3
      #   a = 2
      #   sum(a, b) #=> 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 2 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: does not share binding between examples
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   a, b = 1, 2
      #   sum(a, b) #=> 3
      #
      # @example
      #   sum(a, b) #=> 4
      def sum(one, two)
        one + two
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "NameError: undefined local variable or method `a'"

  Scenario: supports global hooks
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'

      YARD::Doctest.configure do |doctest|
        doctest.before { @flag = false  }
        doctest.after { @flag = true  }
        doctest.after_run { puts 'Run after all by minitest' }
      end
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   flag #=> false
      def flag
        @flag
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "1 runs, 1 assertions, 0 failures, 0 errors, 0 skips"
    And the output should contain "Run after all by minitest"

  Scenario: supports test-name hooks
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'

      YARD::Doctest.before do
        @flag = true
        @foo = true
      end

      YARD::Doctest.before('#flag') do
        @flag = false
        @foo = false
      end
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   flag #=> false
      def flag
        @flag && @foo
      end

      # @example
      #   foo #=> true
      def foo
        @foo && @flag
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "2 runs, 2 assertions, 0 failures, 0 errors, 0 skips"

  Scenario: can skip tests
    Given a file named "doctest_helper.rb" with:
      """
      require 'app/app'

      YARD::Doctest.configure do |doctest|
        doctest.skip '#flag'
        doctest.skip 'A.foo'
      end
      """
    And a file named "app/app.rb" with:
      """
      # @example
      #   flag #=> false
      def flag
        @flag
      end

      class A
        # @example
        #   A.foo => true
        def self.foo
          true
        end
      end
      """
    When I run `bundle exec yard doctest`
    Then the output should contain "0 runs, 0 assertions, 0 failures, 0 errors, 0 skips"
