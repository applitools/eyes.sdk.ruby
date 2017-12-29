require 'rspec/expectations'

RSpec::Matchers.define :match_baseline do |expected, tag|
  match do |actual|
    unless expected.is_a? Applitools::EyesBase
      raise Applitools::EyesIllegalArgument.new(
        "Expected #{expected} to be a Applitools::EyesBase instance, but got #{expected.class.name}."
      )
    end

    eyes_selenium_target = Applitools::ClassName.new('Applitools::Selenium::Target')
    eyes_images_target = Applitools::ClassName.new('Applitools::Images::Target')

    case actual
    when eyes_selenium_target, eyes_images_target
      result = expected.check(tag, actual)
      return result if [TrueClass, FalseClass].include?(result.class)
      return result.as_expected? if result.respond_to? :as_expected?
    else
      false
    end
  end
end
