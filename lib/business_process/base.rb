module BusinessProcess
  class Base
    class_attribute :steps_queue, :requirements
    attr_accessor :result
    attr_reader :parameter_object, :error
    private :result=, :parameter_object

    def self.call(parameter_object)
      new(parameter_object).tap do |business_process|
        business_process.instance_eval do
          self.result = call
          @success = !!self.result unless @success == false
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

    def initialize(parameter_object)
      @parameter_object = parameter_object
    end

    # Defaults to the boolean'ed result of "call"
    def success?
      @success
    end

    def fail(error = nil)
      @error = error
      @success = false
      raise error if error.is_a?(Class) && (error < Exception)
    end

    def self.steps(*step_names)
      self.steps_queue = step_names
    end

    def call
      if steps.present?
        process_steps
      else
        raise NoMethodError, "Called undefined #call. You need either define steps or implement the #call method in the class: #{self.class.name}"
      end
    end

    private

    def process_steps
      _result = nil
      steps.map(&:to_s).each do |step_name|
        _result = process_step(step_name)
        return if @success == false
      end
      _result
    end

    def process_step(step_name)
      if respond_to?(step_name, true)
        send(step_name)
      else
        begin
          step_class = step_name.classify.constantize
          step_class.call(self).result
        rescue NameError => exc
          if step_name.starts_with?('return_') and respond_to?(step_name.sub('return_', ''), true)
            send(step_name.sub('return_', ''))
          else
            raise NoMethodError, "Cannot find step implementation for <#{step_name}>. Step should be either a private instance method of #{self.class.name} or camel_case'd name of another business process class.\n Original exception: #{exc.message}"
          end
        end
      end
    end

    def steps
      self.class.steps_queue || []
    end
  end
end
