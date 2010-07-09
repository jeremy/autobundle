module Autobundle
  def self.setup
    if gemfile = Utils.find_gemfile
      version = Utils.deduce_bundler_version(gemfile)
      gem 'bundler', version
      ENV['BUNDLE_GEMFILE'] = gemfile
      require 'bundler'
      Bundler.setup
    end
  rescue Gem::LoadError => e
    $stderr.puts "You have a Gemfile for bundler #{version} but don't have it installed."
  rescue Bundler::BundlerError => e
    $stderr.puts "You have a Gemfile but your bundle is half-baked. Leaving it in the oven. #{e}"
  end

  module Utils
    # from bundler/shared_helpers
    def self.find_gemfile
      previous = nil
      current  = File.expand_path(Dir.pwd)

      until !File.directory?(current) || current == previous
        filename = File.join(current, 'Gemfile')
        return filename if File.file?(filename)
        current, previous = File.expand_path('..', current), current
      end
    end

    def self.find_gemfile_lock(gemfile)
      lock = "#{File.dirname(gemfile)}/Gemfile.lock"
      lock if File.file?(lock)
    end

    def self.deduce_bundler_version(gemfile)
      if lock = find_gemfile_lock(gemfile)
        contents = File.read(lock)
        if contents =~ /\A---/
          if contents =~ /- bundler:\s*\n\s+version:\s*(.+)\n/
            "= #{$1}"
          else
            '~> 0.9.0'
          end
        elsif contents =~ /bundler \(([^\)]+)\)/
          $1
        else
          '>= 1.0.0.beta.2'
        end
      else
        '>= 1.0.0.beta.2'
      end
    end
  end
end

Autobundle.setup
