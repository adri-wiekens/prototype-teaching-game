module Core
  module DirectoryIncluder
    def require_directory(path_to_directory)
      file_locations = "./#{path_to_directory}/*.rb"
      Dir[file_locations].each do|file|
        full_file_path = File.expand_path(file)
        # Yes this can be done in one line, but this makes
        # debugging missing source files easier
        require_relative(full_file_path)
      end
    end
  end
end