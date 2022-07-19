class SystemObservability::ErrorContextDataFormatters
  @object_data_formatters = {}

  def self.add(klass, fields)
    @object_data_formatters[klass.name] = fields
  end

  def self.get(klass)
    @object_data_formatters[klass.name]
  end

  def self.object_data_formatters
    @object_data_formatters.dup
  end
end
