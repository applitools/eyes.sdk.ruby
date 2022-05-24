module Applitools
  module Selenium
    module ScriptTemplates
      extend self
      def get_script_by_file_name(fname)
        script = nil
        return script unless Dir.exist?(Applitools::JS_PATH)
        begin
          Dir.chdir(Applitools::JS_PATH) do
            script = File.open(File.join('@applitools', 'dom-snapshot', 'dist', "#{fname}.js"), 'r').read
          end
        rescue StandardError => e
          puts e.class
          puts e.message
          script = ''
        end
        script
      end

      # JS_FILES_PATH = File.join(Applitools::JS_PATH, '@applitools', 'dom-snapshot', 'dist')
      #       PROCESS_PAGE_AND_POLL_RB = <<"SCRIPT"
      # module Applitools
      #   module Selenium
      #     module Scripts
      #       PROCESS_PAGE_AND_POLL = <<'END'
      # #{get_script_by_file_name('processPageAndSerializePoll')}
      # END
      #     end
      #   end
      # end
      # SCRIPT
    end
  end
end