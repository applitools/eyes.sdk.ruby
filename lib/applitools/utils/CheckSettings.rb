module Applitools::Utils
  class CheckSettings

    # & {...}
    attr_accessor :name,
      :disableBrowserFetching,
      :layoutBreakpoints,
      :visualGridOptions,
      :hooks,
      :renderId,
      :variationGroupId,
      :timeout

    # MatchSettings
    attr_accessor :exact,
      :matchLevel,
      :sendDom,
      :useDom,
      :enablePatterns,
      :ignoreCaret,
      :ignoreDisplacements,
      :accessibilitySettings,
      :ignoreRegions,
      :layoutRegions,
      :strictRegions,
      :contentRegions,
      :floatingRegions,
      :accessibilityRegions

    # ScreenshotSettings
    attr_accessor :region,
      :frames,
      :scrollRootElement,
      :fully

    def initialize
      @to_socket_output = {}
    end

    def from(check_settings)
      @to_socket_output = prev_conv(check_settings)
    end

    def prev_conv(check_settings)
      _check_settings = check_settings.respond_to?(:to_socket_output) ? check_settings.to_socket_output : check_settings

      if _check_settings[:frames]
        _check_settings[:frames] = _check_settings[:frames].to_a.map {|frame| normalize_element_selector(frame) }
        # _check_settings[:fully] = true if _check_settings[:fully].nil? # TestCheckFrame_Fluent_Scroll
        _check_settings[:ignoreCaret] = true
        _check_settings[:matchLevel] = 'Strict'
      end
      if _check_settings[:scrollRootElement].is_a?(Selenium::WebDriver::Element)
        _check_settings[:scrollRootElement] = normalize_element_selector(_check_settings[:scrollRootElement])
      end
      if _check_settings[:region].is_a?(Selenium::WebDriver::Element)
        _check_settings[:region] = normalize_element_selector(_check_settings[:region])
      end
      if check_settings.is_a?(Hash) && check_settings.size === 1 && check_settings[:target]
        _check_settings = check_settings[:target].respond_to?(:to_socket_output) ? check_settings[:target].to_socket_output : check_settings[:target]
      end

      _check_settings
    end

    def to_socket_output
      method_source = self.instance_of?(Applitools::Utils::CheckSettings) ? self : Applitools::Utils::CheckSettings.new
      keys = (method_source.public_methods(false) - [:to_socket_output, :prev_conv, :from, :json_data]).
        reject {|m| m.to_s.include?('=')}

      values = keys.sort.each_with_object({}) do |k, h|
        v = self.public_send(k)
        if v.respond_to?(:to_socket_output)
          v = v.to_socket_output
        elsif v.respond_to?(:json_data)
          v = v.json_data
        end
        h[k] = v || @to_socket_output[k]
        h[k] = h[k].map {|e| e.respond_to?(:to_socket_output) ? e.to_socket_output : e } if h[k].is_a? Array
      end
      values.compact!
      values
    end

    def json_data
      to_socket_output
    end


    private


    def normalize_element_selector frame
      if Applitools::Selenium::SpecDriver.isElement(frame)
        # new_selector = frame.attribute(:id).empty? ? @set_element_selector_proc.call(frame) : "\##{frame.attribute(:id)}"
        # {type: :css, selector: new_selector}
        {elementId: frame.ref}
      else
        frame
      end
    end

    public

    def accessibility_validation
      accessibilitySettings
    end

    def accessibility_validation=(value)
      raise Applitools::EyesIllegalArgument, "Expected value to be an Applitools::AccessibilitySettings instance but got #{value.class}" unless value.nil? || value.is_a?(Applitools::AccessibilitySettings)
      self.accessibilitySettings = value
    end

  end
end
