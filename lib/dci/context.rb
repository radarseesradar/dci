module DCI

  # Context - The Context is the class (or its instance) whose code includes the roles
  # for a given algorithm, scenario, or use case, as well as the code to map these
  # roles into objects at run time and to enact the use case. Each role is bound
  # to exactly one object during any given use case enactment; however, a single
  # object may simultaneously play several roles. A context is instantiated at the
  # beginning of the enactment of an algorithm, scenario, or use case. In summary,
  # a Context comprises use cases and algorithms in which data objects are used
  # through specific Roles.
  #
  # Each context represents one or more use cases. A context object is instantiated
  # for each enactment of a use case for which it is responsible. Its main job
  # is to identify the objects that will participate in the use case and to
  # assign them to play the Roles which carry out the use case through their
  # responsibilities. A role may comprise methods, and each method is some small
  # part of the logic of an algorithm implementing a use case. Role methods run
  # in the context of an object that is selected by the context to play that role
  # for the current use case enactment. The role-to-object bindings that take place
  # in a context can be contrasted with the polymorphism of vernacular object-oriented
  # programming. The overall business functionality is the sum of complex, dynamic
  # networks of methods decentralized in multiple contexts and their roles.
  #
  # Each context is a scope that includes identifiers that correspond to its roles.
  # Any role executing within that context can refer to the other roles in that
  # context through these identifiers. These identifiers have come to be called
  # methodless roles. At use case enactment time, each and every one of these
  # identifiers becomes bound to an object playing the corresponding Role for
  # this Context.
  #
  # An example of a context could be a wire transfer between two accounts,
  # where data models (the banking accounts) are used through roles named
  # MoneySource and # MoneySink. 
  #
  # class Account
  # 
  #   class TransferFunds < Context
  # 
  #     def initialize(source_account_id, dest_account_id, amount)
  #       @amount = amount
  # 
  #       role MoneySource, Account.find(source_account_id)
  #       role MoneySink, Account.find(dest_account_id)
  #     end
  # 
  #     def call
  #       # Here, money_source refers to the object bound to the MoneySource role
  #       # in the initialize method.
  #       money_source.transfer_out(@amount)
  #     end
  #   end
  # 
  # end
  # 
  # # Now let's create and execute our context.
  # Account::TransferFunds.new(1, 2, 100).call
  #
  class Context

    # Declare a role mapping.
    #
    # This method accepts either two or three arguments. In the three argument
    # form, the arguments are as follows:
    #
    #   role_name:: The name of the role in this context.
    #   role_class:: The module that serves as the "methodful role".
    #   obj:: The data object to which the role_class will be attached.
    #
    # In the two argument form, the role_name is omitted and the role_name
    # is derived from the name of the role_class by converting from
    # CamelCaseName to underscore_name. For instance, if the role_name
    # is not specified, then a role_class called MoneySource would be
    # named money_source.
    #
    def role(*args)

      case args.size
      when 2
        role_class = args[0]
        obj = args[1]
        role_name = Util.underscore(role_class.name).to_sym
      when 3
        role_name = args[0]
        role_class = args[1]
        obj = args[2]
      else
        raise ArgumentError
      end
      
      role_obj = role_class.new( obj )
      
      role_obj.context = self

      self.singleton_class.send(:define_method, role_name) do
        role_obj
      end
      
    end

  end

end
