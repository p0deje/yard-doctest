module YARD
  module CLI
    class Doctest < Command

      def description
        'Doctests from @example tags'
      end

      def run(*args)
        files = args.select { |arg| arg !~ /^-/ }

        files = parse_files(files)
        examples = parse_examples(files)

        add_pwd_to_path
        require_helper

        hooks = {}.tap do |hash|
          hash[:before] = YARD::Doctest.before if YARD::Doctest.before.is_a?(Proc)
          hash[:after] = YARD::Doctest.after if YARD::Doctest.after.is_a?(Proc)
        end

        generate_tests(examples, hooks)
      end

      private

      def parse_files(globs)
        globs = %w(app lib) if globs.empty?

        files = globs.map do |glob|
          if glob !~ /.rb$/
            glob = "#{glob}/**/*.rb"
          end

          Dir[glob]
        end

        files.flatten
      end

      def parse_examples(files)
        YARD.parse(files)
        registry = Registry.load_all
        registry.all.map { |object| object.tags(:example) }.flatten
      end

      def generate_tests(examples, hooks)
        examples.each do |example|
          path = example.object.path
          file = "#{Dir.pwd}/#{example.object.files.first.join(':')}"
          name = example.name
          text = example.text

          text = text.gsub('# =>', '#=>')
          text = text.gsub('#=>', "\n#=>")
          lines = text.split("\n").map(&:strip).reject(&:empty?)

          asserts = [].tap do |arr|
            until lines.empty?
              actual = lines.take_while { |l| l !~ /^#=>/ }
              expected = lines[actual.size] || ''
              lines.slice! 0..actual.size

              arr << {
                expected: expected.sub('#=>', '').strip,
                actual: actual.join("\n"),
              }
            end
          end

          YARD::Doctest::Example.new(path, file, name, asserts, hooks)
        end
      end

      def add_pwd_to_path
        $LOAD_PATH.unshift(Dir.pwd) unless $LOAD_PATH.include?(Dir.pwd)
      end

      def require_helper
        require 'yard-doctest_helper'
      end

    end # Doctest
  end # CLI
end # YARD
