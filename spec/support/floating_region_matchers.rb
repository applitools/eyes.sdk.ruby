RSpec::Matchers.define :include_floating do |expected|
  match do |actual|
    result = false
    expected.each do |fl|
      if fl == actual
        result = true
        break
      end
    end
    result
  end
end


RSpec::Matchers.define :floating_array_match do |expected|
  match do |actual|
    actual.each do |fl|
      expect(fl).to include_floating(expected)
    end
    true
  end
end