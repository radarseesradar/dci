# Context

Let's setup a very simple example to run some tests.

    class ExampleObject
      def say_anything
        "anything"
      end
    end

    class ExampleRole < DCI::Role
      def say_anything
        @self.say_anything + ' from example'
      end
    end

    class ExampleContext < DCI::Context

      def initialize(player)
        role ExampleRole, player
      end

      def call
        example_role.say_anything
      end
    end

    ExampleContext.new( ExampleObject.new ).call  # -> 'anything from example'

