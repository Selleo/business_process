module BusinessProcess
  class Base
    class << self
      attr_accessor :requirements
    end

    def self.call(parameter_object, options={})
      new(parameter_object, options).tap do |business_process|
        business_process.instance_eval do
          self.result = call
        end
      end
    end

    def self.needs(field)
      self.requirements ||= []
      self.requirements << field

      define_method field do
        if parameter_object.is_a?(Hash) && parameter_object.has_key?(field)
          parameter_object[field]
        elsif parameter_object.respond_to?(field)
          parameter_object.public_send(field)
        else
          raise NoMethodError, "Missing method: #{field.inspect} for the parameter object called for class: #{self.class.name}"
        end
      end
    end

    def initialize(parameter_object, options = {})
      @parameter_object = parameter_object
      @options = options
    end

    attr_accessor :result
    attr_reader :parameter_object, :options
    private :result=, :parameter_object, :options

    # Defaults to the boolean'ed result of "call"
    def success?
      !!result
    end

    # Checks if parameter object responds to all methods that process needs
    def valid?
      self.class.requirements.all? { |required_method| parameter_object.respond_to?(required_method) }
    end

    # Business process
    def call
      raise NoMethodError, "Called undefined #call. You need to implement the method in the class: #{self.class.name}"
    end
  end
end
