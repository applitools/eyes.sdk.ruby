require 'rspec'
require 'rspec/shell/expectations'
require 'knapsack'

Knapsack::Adapters::RspecAdapter.bind

RSpec.configure do |c|
  c.include Rspec::Shell::Expectations
end
