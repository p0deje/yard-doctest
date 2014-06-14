require 'yard'
require 'minitest'

require 'yard/cli/doctest'
require 'yard/doctest/example'
require 'yard/doctest/rake'
require 'yard/doctest/version'

module YARD
  module Doctest

    class << self
      def before(&blk)
        block_given? ? @before = blk : @before
      end

      def after(&blk)
        block_given? ? @after = blk : @after
      end

      def after_run(&blk)
        Minitest.after_run &blk
      end
    end

  end # Doctest
end # YARD

YARD::CLI::CommandParser.commands[:doctest] = YARD::CLI::Doctest
