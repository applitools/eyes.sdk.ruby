RSpec::Matchers.define :match_region do |expected|
  match do |actual|
    unless expected.is_a? Applitools::Region
      raise(
        Applitools::EyesIllegalArgument,
        "Expected #{expected} to be a Applitools::Region instance, but got #{expected.class.name}."
      )
    end

    unless actual.is_a? Applitools::Region
      raise(
        Applitools::EyesIllegalArgument,
        "Expected #{actual} to be a Applitools::Region instance, but got #{actual.class.name}."
      )
    end

    expect(actual.x).to eq expected.x
    expect(actual.y).to eq expected.y
    expect(actual.width).to eq expected.width
    expect(actual.height).to eq expected.height
  end
end
