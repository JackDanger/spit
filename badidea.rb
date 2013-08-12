module Injectable
  class Placeholder
    attr_reader :target
    def initialize(target)
      @target = target
    end

    def injected_value
      target.generate
    end
  end
  def self.included(klass)
    klass.extend Generate
  end
  module Generate
    def injectable
      Placeholder.new(self)
    end
  end
end

class Email
  include Injectable
  attr_reader :address
  def initialize(address)
    @address = address
  end
  def self.generate
    new 'email@example.com'
  end
end

require 'logger'
class Logger
  include Injectable
  def self.generate
    new STDOUT
  end
end

class Binding
  def inject
    self.local_variables.each do |name|
      current = local_variable_get(name)
      if current.class <= Injectable::Placeholder
        local_variable_set(name, current.injected_value)
      end
    end
  end

  # Patched in https://bugs.ruby-lang.org/issues/8773
  def local_variables
    eval("local_variables")
  end
end

class BadIdea
  @what = Email.injectable
  def self.run
    logger = Logger.injectable
    email = Email.injectable
    binding.inject
    logger.info(email.address)
  end
end

BadIdea.run
