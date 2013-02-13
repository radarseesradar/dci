require 'dci'
include DCI

class Person
  attr_accessor :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end
end

class Person

  class WifeToBe < Role
    def marry(husband)
      self.last_name = husband.last_name
    end
  end

  class HusbandToBe < Role
    def marry(wife)
    end
  end

  class Minister < Role
    def administer_marraige
      context.husband.marry(context.wife)
      context.wife.marry(context.husband)
      puts("I, #{first_name} #{last_name}, now pronounce you Mr. and Mrs. #{context.wife.last_name}")
    end
  end

end

# In a traditional wedding, a man and a woman are married by a minister.
class TraditionalWedding < Context

  def initialize(man_first_name, man_last_name,
                 woman_first_name, woman_last_name)
    @man = Person.new(man_first_name, man_last_name)
    @woman = Person.new(woman_first_name, woman_last_name)
    @mark = Person.new('Mark', 'Schlafman')

    role :husband, Person::HusbandToBe, @man
    role :wife, Person::WifeToBe, @woman
    role Person::Minister, @mark
  end

  def call
    minister.administer_marraige
  end
end

TraditionalWedding.new('Jason', 'Voegele', 'Jennifer', 'Bollinger').call

