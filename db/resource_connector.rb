require 'yaml'

module Db
  class ResourceConnector
    include Singleton

    # this is a placeholder connector, the information recieved from here 
    # should be returned from a server which provides the game properties that
    # are easily cheated by modification.

    private def mobile_properties
      @mobile_properties = YAML.load_file('assets/yaml/mobile_properties.yaml')
    end

    def get_mobile_properties(id)
      mobile_properties[id]
    end
  end
end