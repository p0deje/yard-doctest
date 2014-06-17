require 'yard'
require 'minitest'
require 'minitest/spec'

require 'yard/cli/doctest'
require 'yard/doctest/example'
require 'yard/doctest/rake'
require 'yard/doctest/version'

module YARD
  module Doctest

    class << self
      #
      # Passed block called before each example and
      # evaluated in the same context as example.
      #
      # @param [Proc] blk
      #
      def before(&blk)
        block_given? ? @before = blk : @before
      end

      #
      # Passed block called after each example and
      # evaluated in the same context as example.
      #
      # @param [Proc] blk
      #
      def after(&blk)
        block_given? ? @after = blk : @after
      end

      #
      # Passed block called after all examples and
      # evaluated in the different context from examples.
      #
      # It actually just sends block to `Minitest.after_run`.
      #
      # @param [Proc] blk
      #
      def after_run(&blk)
        Minitest.after_run &blk
      end
    end

  end # Doctest
end # YARD


YARD::CLI::CommandParser.commands[:doctest] = YARD::CLI::Doctest
