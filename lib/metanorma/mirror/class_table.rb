# frozen_string_literal: true

module Metanorma
  module Mirror
    # A class-keyed lookup with ancestor fallback, in registration
    # order. Consumers register their own model classes to payloads
    # (lambdas, strings, prefixes); the table — and therefore this gem —
    # carries no model knowledge. The metanorma-document and
    # metanorma-standoc seeds register their classes at load time.
    class ClassTable
      def initialize
        @entries = {}
      end

      def register(klass, payload)
        @entries[klass] = payload
        self
      end

      def lookup(instance)
        entry_for(instance.class) || ancestor_entry(instance.class)
      end

      def registered?(klass)
        @entries.key?(klass)
      end

      def empty?
        @entries.empty?
      end

      private

      def entry_for(klass)
        @entries[klass]
      end

      def ancestor_entry(klass)
        klass.ancestors.each do |ancestor|
          next if ancestor == klass
          break if ancestor == Object

          entry = @entries[ancestor]
          return entry if entry
        end
        nil
      end
    end
  end
end
