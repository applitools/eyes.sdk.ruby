# frozen_string_literal: true

RSpec.shared_examples 'responds to method' do |methods|
  methods.each do |m|
    it ":#{m}" do
      expect(subject).to respond_to m
    end
  end
end

RSpec.shared_examples 'responds to class method' do |methods|
  methods.each do |m|
    it ":#{m}" do
      expect(described_class).to respond_to m
    end
  end
end

RSpec.shared_examples 'has private method' do |methods|
  methods.each do |m|
    it ":#{m}" do
      expect(subject.private_methods).to include m
    end
  end
end

RSpec.shared_examples 'has abstract method' do |methods|
  trivial = proc do |m|
    it ":#{m}" do
      expect { subject.send(m) }.to raise_error(Applitools::AbstractMethodCalled)
    end
  end

  case methods
  when Array
    methods.each do |m|
      trivial.call(m)
      # it ":#{m}" do
      #   expect { subject.send(m) }.to raise_error(Applitools::AbstractMethodCalled)
      # end
    end
  when Hash
    methods.keys.each do |m|
      if methods[m].is_a? Array
        it ":#{m}" do
          expect { subject.send(m, *methods[m]) }.to raise_error(Applitools::AbstractMethodCalled)
        end
      else
        trivial.call(m)
      end
    end
  end
end

RSpec.shared_examples 'has environment attribute' do |m, env_key|
  it ":#{m}" do
    expect(subject).to respond_to m
  end
  it ":#{m}=" do
    expect(subject).to respond_to "#{m}="
  end
  it ":#{m} checks env_key #{env_key}" do
    subject.instance_variable_set("@#{m}".to_sym, nil)
    allow(Applitools::Helpers.instance_variable_get(:@environment_variables)).to(
      receive('[]').with(env_key.to_sym).and_return("ENV#{m}")
    )
    expect(subject.send(m)).to eq "ENV#{m}"
  end
end
