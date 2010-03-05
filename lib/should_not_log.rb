module ActionController
  class Base
    def self.should_not_log(*actions)
      @@non_logging_actions ||= {}
      @@non_logging_actions[self] ||= []
      @@non_logging_actions[self] += actions
      around_filter :should_not_log, :only => [actions]
    end

    def should_not_log(&block)
      logger.silence do
        perform_action_without_benchmark do
          yield block
        end
      end
    end

    # also shut the default logging up
    alias_method :loud_log_processing_for_request_id, :log_processing_for_request_id
    def log_processing_for_request_id
      loud_log_processing_for_request_id unless should_not_log?
    end

    alias_method :loud_log_processing_for_parameters, :log_processing_for_parameters
    def log_processing_for_parameters
      loud_log_processing_for_parameters unless should_not_log?
    end

    def should_not_log?
      @@non_logging_actions ||= {}
      if as = @@non_logging_actions[self.class]
        as.include?(action_name.to_sym)
      end
    end
  end
end
