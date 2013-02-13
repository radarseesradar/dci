module DCI

  # Interaction - The Interaction is "what the system does." The Interaction
  # is implemented as Roles which are played by objects at run time. These objects
  # combine the state and methods of a Data (domain) object with methods (but no
  # state, as Roles are stateless) from one or more Roles. In good DCI style,
  # a Role addresses another object only in terms of its (methodless) Role. There
  # is a special Role called `@player` which binds to the object playing the current
  # Role. Code within a Role method may invoke a method on `@player` and thereby
  # invoke a method of the Data part of the current object. One curious aspect
  # of DCI is that these bindings are guaranteed to be in place only at run time
  # (using a variety of approaches and conventions; C++ templates can be used to
  # guarantee that the bindings will succeed). This means that Interactions—the
  # Role methods—are generic. In fact, some DCI implementations use generics or
  # templates for Roles.
  #
  # A Role is a stateless programming construct that corresponds to the end user's
  # mental model of some entity in the system. A Role represents a collection of 
  # responsibilities. Whereas vernacular object-oriented programming speaks of
  # objects or classes as the loci of responsibilities, DCI ascribes them to Roles.
  # An object participating in a use case has responsibilities: those that it takes
  # on as a result of playing a particular Role.
  #
  # In the money transfer use case, for example, the role methods in the
  # MoneySource and MoneySkin enact the actual transfer.
  #
  #   class Account  
  #
  #     class MoneySource < Role
  #       def transfer_out(amount)
  #         log "Transferring #{amount} from account #{self.id} to account #{context.money_sink.id}"
  #         self.balance -= amount
  #         log "Source account new balance: #{self.balance}"
  #         context.money_sink.transfer_in(amount)
  #       end
  #     end
  #
  #     class MoneySink < Role
  #       def transfer_in(amount)
  #         self.balance += amount
  #         log "Destination account new balance: #{self.balance}"
  #       end
  #     end
  #
  #  end
  #
  class Role
    
    attr_accessor :context

    #
    def initialize(player)
      @player = player
    end

    #
    # @todo Should use #public_send?
    def method_missing(s, *a, &b)
      @player.__send__(s, *a, &b)
    end

  end

end
