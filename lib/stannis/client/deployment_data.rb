class Stannis::Client::DeploymentData
  attr_reader :label, :value, :indicator
  def initialize(label, value, indicator="ok")
    @label = label
    @value = value
    @indicator = indicator
  end
  def validation_errors
    errors = []
    errors << "missing label" unless label && label.size > 0
    errors << "missing value" unless value && value.size > 0
    errors
  end
end
