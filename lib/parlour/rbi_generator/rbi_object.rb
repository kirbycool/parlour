# typed: true
module Parlour
  class RbiGenerator
    # An abstract class which is subclassed by any classes which can generate
    # entire lines of an RBI, such as {Namespace} and {Method}. (As an example,
    # {Parameter} is _not_ a subclass because it does not generate lines, only
    # segments of definition and signature lines.)
    # @abstract
    class RbiObject
      extend T::Helpers
      extend T::Sig
      abstract!

      sig { params(generator: RbiGenerator, name: String).void }
      # Creates a new RBI object. Don't call this directly.
      # @param generator The current RbiGenerator.
      # @param name The name of this module.
      def initialize(generator, name)
        @generator = generator
        @generated_by = generator.current_plugin
        @name = name
        @comments = []
      end

      sig { returns(RbiGenerator) }
      # The generator which this object belongs to.
      attr_reader :generator

      sig { returns(T.nilable(Plugin)) }
      # The {Plugin} which was controlling the {generator} when this object was
      # created.
      attr_reader :generated_by

      sig { returns(String) }
      # The name of this object.
      attr_reader :name

      sig { returns(T::Array[String]) }
      # An array of comments which will be placed above the object in the RBI
      # file.
      attr_reader :comments

      sig { params(comment: String).void }
      # Adds a comment to this RBI object.
      # @param comment The new comment.
      def add_comment(comment)
        comments << comment
      end

      sig do
        params(
          indent_level: Integer,
          options: Options
        ).returns(T::Array[String])
      end
      # Generates the RBI lines for this object's comments.
      # @param indent_level The indentation level to generate the lines at.
      # @param options The formatting options to use.
      # @return The RBI lines for each comment, formatted as specified.
      def generate_comments(indent_level, options)
        comments.any? \
          ? comments.map { |c| options.indented(indent_level, "# #{c}") }
          : []
      end

      sig do
        abstract.params(
          indent_level: Integer,
          options: Options
        ).returns(T::Array[String])
      end
      # Generates the RBI lines for this object.
      # @abstract
      # @param indent_level The indentation level to generate the lines at.
      # @param options The formatting options to use.
      # @return The RBI lines, formatted as specified.
      def generate_rbi(indent_level, options); end

      sig do
        abstract.params(
          others: T::Array[RbiGenerator::RbiObject]
        ).returns(T::Boolean)
      end
      # Given an array of other objects, returns true if they may be merged
      # into this instance using {merge_into_self}. Each subclass will have its
      # own criteria on what allows objects to be mergeable.
      # @abstract
      # @param others An array of other {RbiObject} instances.
      # @return Whether this instance may be merged with them.
      def mergeable?(others); end

      sig do 
        abstract.params(
          others: T::Array[RbiGenerator::RbiObject]
        ).void
      end
      # Given an array of other objects, merges them into this one. Each
      # subclass will do this differently.
      # @abstract
      # You MUST ensure that {mergeable?} is true for those instances.
      # @param others An array of other {RbiObject} instances.
      def merge_into_self(others); end

      sig { abstract.returns(String) }
      # Returns a human-readable brief string description of this object. This
      # is displayed during manual conflict resolution with the +parlour+ CLI.
      # @abstract
      def describe; end
    end
  end
end