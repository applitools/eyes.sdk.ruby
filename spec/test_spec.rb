require 'spec_helper'

RSpec.describe 'test' do

  after do
    puts "111"
  end

  after do
    puts "222"
  end

  it do |e|
    e.example_group.append_after do
      puts "333"
    end
    require 'pry'
    binding.pry
  end

  it do

  end
end