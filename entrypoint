#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'

# Set environment
ENV_FILE_REGEX = /^\s*ENV_FILE_(?<name>[_A-Z0-9]+)=(?<path>.+\.env)\s*$/
ENVIRONMENT_REGEX = /^\s*(?<name>[^#][^=]+)[=](?<value>.+)$/

# Export environment variables from file if provided
ENV.map { |k, v| ENV_FILE_REGEX.match("#{k}=#{v}") }.compact.each do |match|
  break unless File.exists?(match[:path])
  env_file = File.open(match[:path]).read
  env_file.gsub!(/\r\n?/, "\n")
  env_file.each_line do |env_line|
    match = ENVIRONMENT_REGEX.match(env_line)
    ENV[match[:name]] = match[:value] if match
  end
end

# Prepare the bundle config if BUNDLE_PATH is provided in order to avoid
# inconsistencies with how the bundler path is used
if ENV['BUNDLE_PATH']
  bundle_config_dir = ENV['BUNDLE_APP_CONFIG'] || './.bundle'
  config_file = File.join(bundle_config_dir, 'config')
  default_config = { 'BUNDLE_PATH' => ENV['BUNDLE_PATH'] }
  current_config = File.exists?(config_file) ? YAML.load(File.open(config_file)) : {}
  unless current_config['BUNDLE_PATH'] == default_config['BUNDLE_PATH']
    current_config['BUNDLE_PATH'] = default_config['BUNDLE_PATH']
    FileUtils.mkdir_p(bundle_config_dir)
    File.open(config_file, 'w') { |f| f.write(current_config.to_yaml) }
  end
end

# Execute an application specific entrypoint if present
ARGV.unshift('/usr/src/web/entrypoint') if File.exist?('/usr/src/web/entrypoint')

# Execute the passed in command if provided
exec(*ARGV) if ARGV.size > 0
