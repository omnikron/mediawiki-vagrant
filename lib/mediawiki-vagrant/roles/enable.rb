require 'mediawiki-vagrant/plugin_environment'
require 'mediawiki-vagrant/settings_plugin'

module MediaWikiVagrant
  module Roles
    class Enable < Vagrant.plugin(2, :command)
      include PluginEnvironment
      include SettingsPlugin

      def self.synopsis
        'enables a mediawiki-vagrant role'
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles enable <name> [<name2> <name3> ...] [-h]'
          o.separator ''
          o.separator '  Enable an optional role (run `vagrant roles list` for a list).'
          o.separator ''
        end

        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, help: opts.help.chomp if argv.length < 1

        avail = @mwv.roles_available
        roles = argv.map(&:downcase)

        roles.each do |r|
          unless avail.include? r
            @env.ui.error "'#{r}' is not a valid role."
            return 1
          end
        end

        new_roles = @mwv.roles_enabled + roles
        changes = @mwv.load_settings(new_roles) - @mwv.load_settings

        @mwv.update_roles(new_roles)

        @env.ui.info 'Ok. Run `vagrant provision` to apply your changes.'
        describe_settings_changes(changes)

        0
      end
    end
  end
end
