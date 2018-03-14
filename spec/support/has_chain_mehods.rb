# frozen_string_literal: true

RSpec.shared_examples 'has chain methods' do |methods|
  methods.keys.each do |method|
    it "responds to #{method}" do
      expect(subject).to respond_to method
    end

    it "#{method} returns self" do
      if methods[method].is_a? Array
        expect(subject.send(method, *methods[method]).object_id).to eq subject.object_id
      else
        expect(subject.send(method).object_id).to eq subject.object_id
      end
    end
  end
end
