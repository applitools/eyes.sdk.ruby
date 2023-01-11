# frozen_string_literal: true

module DockerFilesList
  extend self
  def dockerfiles
    docker_files_dir = 'dockerfiles'
    Dir.entries(docker_files_dir).select { |f| File.file?("#{docker_files_dir}/#{f}") }.each do |dockerfile|
      yield dockerfile, docker_files_dir if block_given?
    end
  end
end
