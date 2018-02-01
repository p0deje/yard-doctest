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

          %w[. support spec].each do |dir|
            require "#{dir}/doctest_helper" if File.exist?("#{dir}/doctest_helper.rb")
          end

          return if YARD::Doctest.skips.any? { |skip| this.definition.include?(skip) }

          begin
            object_name = this.definition.split(/#|\./).first
            scope = Object.const_get(object_name) if const_defined?(object_name)
          rescue NameError
          end

          describe this.definition do
            # Append this.name to this.definition if YARD's @example tag is followed by
            # descriptive text, to support hooks for multiple examples per code object.
            example_name = if this.name.empty?
                             this.definition
                           else
                             "#{this.definition}@#{this.name}"
                           end

            register_hooks(example_name, YARD::Doctest.hooks)

            it this.name do
              constants = Object.constants
              this.asserts.each do |assert|
                expected, actual = assert[:expected], assert[:actual]
                if expected.empty?
                  evaluate_example(this, actual, scope)
                else
                  assert_example(this, expected, actual, scope)
                end
              end
              clear_extra_constants(constants)
            end
          end
        end
      end

      protected

      def evaluate_example(example, actual, bind)
        evaluate(actual, bind)
      rescue StandardError => error
        add_filepath_to_backtrace(error, example.filepath)
        raise error
      end

      def assert_example(example, expected, actual, bind)
        assert_equal(evaluate_with_assertion(expected, bind),
                     evaluate_with_assertion(actual, bind))
      rescue Minitest::Assertion => error
        add_filepath_to_backtrace(error, example.filepath)
        raise error
      end

      def evaluate_with_assertion(code, bind)
        evaluate(code, bind)
      rescue StandardError => error
        "#<#{error.class}: #{error}>"
      end

      def evaluate(code, bind)
        context.eval code
      rescue NameError
        bind ? bind.__send__(:eval, code) : raise
      end

      def context
        @binding ||= binding
      end

      def add_filepath_to_backtrace(exception, filepath)
        backtrace = exception.backtrace
        line = backtrace.find { |l| l =~ %r{lib/yard/doctest/example} }
        index = backtrace.index(line)
        backtrace = backtrace.insert(index + 1, filepath)
        exception.set_backtrace backtrace
      end

      def clear_extra_constants(constants)
        (Object.constants - constants).each do |constant|
          Object.__send__(:remove_const, constant)
        end
      end

      def self.register_hooks(example_name, all_hooks)
        all_hooks.each do |type, hooks|
          global_hooks = hooks.select { |hook| !hook[:test] }
          test_hooks = hooks.select { |hook| hook[:test] && example_name.include?(hook[:test]) }
          __send__(type) do
            (global_hooks + test_hooks).each { |hook| instance_exec(&hook[:block]) }
          end
        end
      end

    end # Example
  end # Doctest
end # YARD
