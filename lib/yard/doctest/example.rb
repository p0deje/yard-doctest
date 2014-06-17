require 'sourcify'

module YARD
  module Doctest
    class Example < ::Minitest::Spec

      # @return [String] namespace path of example (e.g. `Foo#bar`)
      attr_accessor :definition

      # @return [String] filepath to definition (e.g. `app/app.rb:10`)
      attr_accessor :filepath

      # @return [Array<Hash>] assertions to be done
      attr_accessor :asserts

      #
      # Generates a spec and registers it to Minitest runner.
      #
      def generate
        this = self

        Class.new(this.class).class_eval do
          require 'minitest/autorun'
          require 'yard-doctest_helper'

          describe this.definition do
            before { evaluate YARD::Doctest.before } if YARD::Doctest.before.is_a?(Proc)
            after  { evaluate YARD::Doctest.after  } if YARD::Doctest.after.is_a?(Proc)

            it this.name do
              this.asserts.each do |assert|
                expected, actual = assert[:expected], assert[:actual]
                actual = context.eval(actual)

                unless expected.empty?
                  begin
                    assert_equal evaluate(expected), actual
                  rescue Minitest::Assertion => error
                    add_filepath_to_backtrace(error, this.filepath)
                    raise error
                  end
                end
              end
            end
          end
        end
      end

      protected

      def evaluate(code)
        code = code.to_source(strip_enclosure: true) if code.is_a?(Proc)
        context.eval(code)
      end

      def context
        @binding ||= binding
      end

      def add_filepath_to_backtrace(exception, filepath)
        backtrace = exception.backtrace
        line = backtrace.find { |line| line =~ %r(lib/yard/doctest/example) }
        index = backtrace.index(line)
        backtrace = backtrace.insert(index, filepath)
        exception.set_backtrace backtrace
      end

    end # Example
  end # Doctest
end # YARD
