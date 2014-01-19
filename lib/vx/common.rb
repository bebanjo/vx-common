require File.expand_path("../common/version", __FILE__)

module Vx
  module Common
    module Helper
      autoload :Shell,           File.expand_path("../common/helper/shell",             __FILE__)
      autoload :Middlewares,     File.expand_path("../common/helper/middlewares",       __FILE__)
      autoload :UploadShCommand, File.expand_path("../common/helper/upload_sh_command", __FILE__)
    end

    autoload :OutputBuffer,  File.expand_path("../common/output_buffer",      __FILE__)
    autoload :EnvFile,       File.expand_path("../common/env_file",           __FILE__)
    autoload :ErrorNotifier, File.expand_path("../common/error_notifier",     __FILE__)
  end

  module SCM
    autoload :Git, File.expand_path("../scm/git", __FILE__)
  end

end
