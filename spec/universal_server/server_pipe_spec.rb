require 'spec_helper'

RSpec.describe "Termination tests for u-sdk #{RUBY_PLATFORM}", universal_server: true do

  it 'server finish on :in close' do
    universal_server_control = Applitools::Connectivity::UniversalServerControl.instance

    expect(universal_server_control.server_running?).to be(true)
    expect(universal_server_control.server_port).to be >= 21077
    socket = universal_server_control.new_server_socket_connection
    expect(socket).to be_instance_of(TCPSocket)

    sleep(10) # still working
    expect(universal_server_control.server_running?).to be(true)

    universal_server_control.stop_server

    expect(universal_server_control.server_running?).to be(false)
  end

end
