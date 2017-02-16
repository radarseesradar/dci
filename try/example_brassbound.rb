require 'dci'

# Domain/data objects are plain old Ruby objects.
class Account
  # Pretend to lookup accounts in a database.
  def self.find(account_id)
    case account_id
    when 1
      Account.new(account_id, 2000)
    when 2
      Account.new(account_id, 1000)
    end
  end

  attr_reader   :id
  attr_accessor :balance

  def initialize(id, balance)
    @id = id
    @balance = balance
  end
end

# Roles are subclasses of class Role.
# Notice that roles collaborate with other roles via the context.
# Notice that simple non-role types (e.g. amount) are passed as arguments.
class Account

  class MoneySource < DCI::Role
    def transfer_out(amount, money_sink = context.money_sink)
      puts("Transferring #{amount} from account #{self.id} to account #{context.money_sink.id}")
      self.balance -= amount
      puts("Source account new balance: #{self.balance}")
      money_sink.transfer_in(amount)
    end
  end

  class MoneySink < DCI::Role
    def transfer_in(amount)
      self.balance += amount
      puts("Destination account new balance: #{self.balance}")
    end
  end

end

# Contexts are subclasses of context.
# The common idiom is for the initialize method to create all of the
# necessary objects and declare how they are bound to roles.
# Then, within the scope of the call method, the objects will have been
# bound to the declared roles, and can be accessed by the role name
# (convert to lower case with underscores by default).
class Account

  class TransferFunds < DCI::Context

    def initialize(source_account_id, dest_account_id, amount)
      @amount = amount

      role MoneySource, Account.find(source_account_id)
      role MoneySink, Account.find(dest_account_id)
    end

    def call
      # Here, money_source refers to the object bound to the MoneySource role
      # in the initialize method.
      money_source.transfer_out(@amount)
    end
  end

end

# Now let's create and execute our context.
Account::TransferFunds.new(1, 2, 100).call

