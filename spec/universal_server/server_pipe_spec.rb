require 'spec_helper'

RSpec.describe "Termination tests for u-sdk #{RUBY_PLATFORM}", universal_server: true do

  let(:filepath) do
    Applitools::Connectivity::UniversalServer.send(:filepath)
  end

  it 'server finish on :in close' do
    in_r, in_w = IO.pipe
    r, w = IO.pipe
    usdk_pid = spawn([filepath, '--no-singleton'], '--shutdown-mode', 'stdin',
                     in: in_r,
                     out: w,
                     err: w,
                     close_others: true
    )
    in_r.close_read
    w.close_write

    # server started and gives a port number
    port = r.readline.strip
    r.close_read
    expect(port).to be_instance_of(String)
    expect(port.to_i).to be >= 21077

    monitoring_thread = Process.detach(usdk_pid)
    sleep(1)

    monitoring_result = monitoring_thread.join(1) # server working
    expect(monitoring_result).to be_nil
    sleep(10)
    monitoring_result = monitoring_thread.join(1) # server still working
    expect(monitoring_result).to be_nil

    in_w.close_write
    sleep(1)

    monitoring_result = monitoring_thread.join(1) # server stopped
    expect(monitoring_result).to be_instance_of(Process::Waiter)
    expect(monitoring_result.value.success?).to be(true)
    expect(monitoring_result.value.to_i).to be(0)
  end

end
