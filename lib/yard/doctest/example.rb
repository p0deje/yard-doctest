require 'sourcify'

module YARD
  module Doctest
    class Example

      #
      # There are a bunch of hacks happening here:
      #
      #   1. Everything is done within constructor.
      #   2. Context (binding) is shared between helper, example and hooks.
      #   3. Since hooks are blocks, they can't be passed to `#eval`,
      #      so we translate them into string of Ruby code.
      #   4. Intercept exception backtrace and add example object definition path.
      #

      def initialize(path, file, name, asserts, hooks)
        Object.instance_eval do
          context = binding

          require 'minitest/autorun'
          context.eval "require 'yard-doctest_helper'"

          describe path do
            before { context.eval(hooks[:before].to_source(strip_enclosure: true)) } if hooks[:before]
            after { context.eval(hooks[:after].to_source(strip_enclosure: true)) } if hooks[:after]

            it name do
              asserts.each do |assert|
                expected, actual = assert[:expected], assert[:actual]
                actual = context.eval(actual)

                unless expected.empty?
                  begin
                    assert_equal context.eval(expected), actual
                  rescue Minitest::Assertion => e
                    backtrace = e.backtrace
                    example = backtrace.find { |trace| trace =~ %r(lib/yard/doctest/example) }
                    example = backtrace.index(example)
                    backtrace = backtrace.insert(example, file)
                    e.set_backtrace backtrace
                    raise e
                  end
                end
              end
            end
          end
        end
      end

    end # Example
  end # Doctest
end # YARD
