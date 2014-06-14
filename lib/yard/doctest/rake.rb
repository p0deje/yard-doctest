require 'rake'
require 'rake/tasklib'

module YARD
  module Doctest
    class RakeTask < ::Rake::TaskLib

      attr_accessor :name
      attr_accessor :doctest_opts
      attr_accessor :pattern

      def initialize(name = 'yard:doctest')
        @name = name
        @doctest_opts = []
        @pattern = ''

        yield self if block_given?

        define
      end

      protected

      def define
        desc 'Run YARD doctests'
        task(name) do
          command = "yard doctest #{(doctest_opts << pattern).join(' ')}"
          system(command)
        end
      end

    end # RakeTask
  end # Doctest
end # YARD
