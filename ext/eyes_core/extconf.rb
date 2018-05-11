# frozen_string_literal: true

require 'mkmf'
$CFLAGS << ' -Wall'
create_makefile('eyes_core/eyes_core')
