module Presenter
  class Base
    FILTERED_PARAMS = {
      :authenticity_token => nil,
      :commit => nil
    }

    attr_reader :options

    def initialize(template, options = {})
      @template, @options = template, options
    end

    # TODO: Figure out why this is needed for Haml to work in initialize.
    def initialize_template(template)
      @template = template

      unless @template.is_haml?
        class << @template
          include Haml::Helpers

          def _hamlout
            haml_buffer
          end
        end

        @template.init_haml_helpers
      end
    end

    def method_missing(method_name, *args, &block)
      @template.send(method_name, *args, &block) if @template.respond_to?(method_name)
    end

    # TODO: Figure out why this is needed to avoid the ERB::Util method.
    def t(*args)
      @template.t(*args)
    end

    def filter_params(params)
      params.reverse_merge(FILTERED_PARAMS)
    end
  end
end