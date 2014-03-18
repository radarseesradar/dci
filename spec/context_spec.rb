require 'spec_helper'
require 'dci'
include DCI

class Account
  @accounts = {}
  def self.find(account_id)
    case account_id
    when 1
      @accounts[account_id] ||= Account.new(200)
    when 2
      @accounts[account_id] ||= Account.new(100)
    end
  end

  attr_accessor :balance

  def initialize(balance)
    @balance = balance
  end
  
  private
  
  def private_method
  end
end

class MoneySource < Role
  def transfer_out(amount)
    self.balance -= amount
    context.dest_account.transfer_in(amount)
  end
end

class MoneySink < Role
  def transfer_in(amount)
    self.balance += amount
  end
end

class TransferFunds < Context

  def initialize(source_account_id, dest_account_id, amount)
    @source_account_id = source_account_id
    @dest_account_id = dest_account_id
    @amount = amount

    role :source_account, MoneySource, Account.find(@source_account_id)
    role :dest_account, MoneySink, Account.find(@dest_account_id)
  end

  def call
    source_account.transfer_out(@amount)
    # Allow spec to access the executing context for testing
    yield self if block_given?
  end
end

describe Context do

  let(:source_account_id) { 1 }
  let(:dest_account_id) { 2 }
  let(:source_account) { Account.find(source_account_id) }
  let(:dest_account) { Account.find(dest_account_id) }

  let(:transfer_funds_context) {
    TransferFunds.new(source_account_id, dest_account_id, 50)
  }

  context "#role" do
    it "declares a role mapping" do
      subject.role MoneySource, source_account
      mapping = subject.money_source
      mapping.class.should == Account
      mapping.should == source_account
      mapping.should respond_to(:balance)
      mapping.should respond_to(:transfer_out)
      mapping.should_not respond_to(:transfer_in)
      mapping.should_not respond_to(:private_method)
      expect {mapping.private_method}.to raise_error(NoMethodError)
      
      subject.role :money_sink, MoneySink, dest_account
      mapping = subject.money_sink
      mapping.class.should == Account
      mapping.should == dest_account
      mapping.should respond_to(:balance)
      mapping.should_not respond_to(:transfer_out)
      mapping.should respond_to(:transfer_in)
      mapping.should_not respond_to(:private_method)
      expect {mapping.private_method}.to raise_error(NoMethodError)
    end
  end

  context "#call" do
    it "binds all roles to their mapped objects" do
      transfer_funds_context.call do |ctx|
        ctx.source_account.should == source_account
        ctx.source_account.should be_kind_of(Account)
        ctx.source_account.should be_instance_of(Account)
        ctx.source_account.should respond_to(:transfer_out)
        ctx.source_account.should_not respond_to(:transfer_in)

        ctx.dest_account.should == dest_account
        ctx.dest_account.should be_kind_of(Account)
        ctx.dest_account.should be_instance_of(Account)
        ctx.dest_account.should respond_to(:transfer_in)
        ctx.dest_account.should_not respond_to(:transfer_out)
      end
    end
  end

end

