require "cfoundry"

class Stannis::Plugin::CfUsage::CfClient
  def initialize(cf_config)
    @cf_config = cf_config
    @cf = CFoundry::V2::Client.new(@cf_config["api"])
  end

  def login
    @cf.login({username: @cf_config["username"], password: @cf_config["password"]})
  end

  def get(*args)
    JSON.parse(@cf.base.get(*args))
  end

  def post(*args)
    JSON.parse(@cf.base.post(*args))
  end

  def put(*args)
    JSON.parse(@cf.base.put(*args))
  end

  def delete(*args)
    JSON.parse(@cf.base.delete(*args))
  end
end
