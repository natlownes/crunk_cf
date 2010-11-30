# crunk_cf verb 'version' /etc/
# verb = 'use', 'use_dry'
# last arg = base directory.  /etc by default
require 'fileutils'
require 'find'
module Crunk
  module CF
    def self.run!(verb, version, base_dir=nil, named_run_id=nil)
      config[:verb] = verb.to_sym
      config[:target_version] = version
      config[:base_dir] = base_dir || '/etc'
      config[:run_id] = named_run_id || Time.now.to_i
      method_name = self.config[:verb]
      self.send(method_name) if self.respond_to?(method_name)
    end

    def self.file_library
      if self.config[:verb] == :run
        FileUtils::Verbose
      else
        FileUtils::DryRun
      end
    end

    def self.file_extension
      'crunk_cf'
    end

    def self.run
      migration = Crunk::CF::Migration.new(self.config)
      migration.run!
    end

    def self.dry_run
      self.run
    end

    def self.config
      @config ||= {}
    end

    class Migration

      def initialize(config={})
        @files_to_migrate = Crunk::CF::ConfigFile.find_all_for_version(config[:target_version])
      end

      def run!
        @files_to_migrate.each {|config_file| config_file.make_active!}
      end
    end

    class ConfigFile
      def self.find_all
        files = []
        Find.find(Crunk::CF.config[:base_dir]) do |path|
          if File.basename(path).match(%r{.\.#{Crunk::CF.file_extension}})
            files << self.new(path)
          end
        end
        files
      end

      def self.find_all_for_version(version)
        self.find_all.select {|configfile| configfile.version == version }
      end

      def initialize(path)
        @full_path = File.expand_path(path)
        @filename = File.basename(path)
        @directory = File.dirname(@full_path)
        @cf_data = @filename.split('.')[-2..-1]
        @cf_string = '.' + @cf_data.join('.')
      end

      def make_active!
        if would_replace_existing_file?
          backup_target_file()
        end
        Crunk::CF.file_library.cp(@full_path, self.target)
      end

      def version
        @cf_data[0]
      end

      def target_file_name
        @filename.gsub(@cf_string, '')
      end

      def target
        @directory + File::SEPARATOR + self.target_file_name
      end

      def would_replace_existing_file?
        File.exists?(self.target)
      end

      def backup_target_file
        Crunk::CF.file_library.cp(self.target, (@directory + File::SEPARATOR + self.target_file_name + ".backup-#{Crunk::CF.config[:run_id]}.#{Crunk::CF.file_extension}"))
      end
    end

  end
end
