# frozen_string_literal: true

class SystemObservability::ErrorContextDataFormatters
  @object_data_formatters = {}

  def self.add(klass, formatter = proc {})
    @object_data_formatters[klass.name] = formatter
  end

  def self.get(klass)
    @object_data_formatters[klass.name]
  end

  def self.object_data_formatters
    @object_data_formatters.dup
  end
end
