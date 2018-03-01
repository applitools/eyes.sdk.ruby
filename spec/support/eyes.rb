# frozen_string_literal: true

CURRENT_RUBY_VERSION = Gem::Version.new RUBY_VERSION

RUBY_1_9_3 = Gem::Version.new '1.9.3'
RUBY_2_0_0 = Gem::Version.new '2.0.0'
RUBY_2_1_6 = Gem::Version.new '2.1.6'
RUBY_2_2_2 = Gem::Version.new '2.2.2'
RUBY_2_4_0 = Gem::Version.new '2.4.0'

RUBY_KEY = [RUBY_1_9_3, RUBY_2_0_0, RUBY_2_1_6, RUBY_2_2_2, RUBY_2_4_0].select { |v| v <= CURRENT_RUBY_VERSION }.last

RSpec.shared_examples 'can be disabled' do |method, args|
  it 'checks disabled? before a test' do
    expect(subject).to receive(:disabled?).and_return(true)
    expect(subject).to_not receive(:check_window_base)
    subject.send(method, *args)
  end

  it 'returns false if disabled' do
    allow(subject).to receive(:disabled?).and_return(true)
    expect(subject).to_not receive(:check_window_base)
    expect(subject.send(method, *args)).to be false
  end
end
