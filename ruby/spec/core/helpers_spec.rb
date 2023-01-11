# frozen_string_literal: true
require 'spec_helper'

class Foo
  extend Applitools::Helpers
  environment_attribute :bar, 'BAR'
end

RSpec.describe 'Applitools::Helpers' do
  context 'environment attribute' do
    let(:foo_instance) { Foo.new }
    before do
      Applitools::Helpers.instance_variable_get(:@environment_variables)['BAR'.to_sym] = nil
      allow(ENV).to receive('[]').with('X').and_return('Y')
    end
    it 'returns explicitly set value' do
      foo_instance.bar = 'test'
      expect(foo_instance.bar).to eq 'test'
    end
    it 'returns environment variable if wasn\'t explixitly set' do
      Applitools::Helpers.instance_variable_get(:@environment_variables)['BAR'.to_sym] = 'LIKE ENV'
      expect(foo_instance.bar).to eq 'LIKE ENV'
    end
    it 'returns nil if nothing was set' do
      expect(foo_instance.bar).to be nil
    end
    it 'takes appropriate environment variable' do
      class Foo1
        extend Applitools::Helpers
        environment_attribute :bar, :X
      end
      expect(Foo1.new.bar).to eq 'Y'
    end

    it 'sets the instance variable after the first access' do
      class Foo2
        extend Applitools::Helpers
        environment_attribute :bar, :X
      end
      instance = Foo2.new
      expect(instance.bar).to eq 'Y'
      expect(instance.instance_variable_get(:@bar)).to eq 'Y'
    end
  end
end
