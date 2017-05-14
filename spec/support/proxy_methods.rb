RSpec.shared_examples 'proxy method' do |receiver, methods|
  methods.each do |m|
    it "responds to #{m}" do
      expect(subject).to respond_to(m)
    end
    it "#{m} to #{receiver}" do
      expect(receiver).to receive(m).at_least 1
      subject.send m, nil
    end
  end
end

RSpec.shared_examples 'proxy to object method' do |receiver, methods|
  methods.each do |m|
    it "responds to #{m}" do
      expect(subject).to respond_to(m)
    end
    it "#{m} to #{receiver}" do
      obj = Object.new
      expect(subject).to receive(receiver).and_return obj
      expect(obj).to receive(m).with(any_args).at_least 1
      arity = subject.method(m).arity
      subject.send m, *Array.new(arity < 0 ? (arity + 1).abs : arity)
    end
  end
end
