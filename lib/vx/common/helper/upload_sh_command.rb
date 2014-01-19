require 'base64'

module Vx
  module Common
    module Helper
      module UploadShCommand

        def upload_sh_command(path, content, options = {})
          encoded = ::Base64.encode64(content).gsub("\n", '')
          "(echo #{encoded} | #{upload_sh_base64_command options}) > #{path}"
        end

        private

          def upload_sh_base64_command(options)
            %{base64 --decode}
          end

      end
    end
  end
end
