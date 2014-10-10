require 'nsconfig'
require 'logger'

module LiveStatus
    extend NSConfig
    self.config_path= File.join File.dirname(__FILE__), 'config'

    LiveStatus::SinatraRoot = File.dirname(__FILE__)

    $logger = Logger.new(STDOUT)
    $logger.level = Logger::INFO
end
