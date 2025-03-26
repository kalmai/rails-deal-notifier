# frozen_string_literal: true

set :bundle_cmd, '/home/deploy/.rvm/gems/ruby-3.4.1@global/bin/.bundle'
set :bundle_dir, '/home/deploy/.rvm/gems/ruby-3.4.1'

# config valid for current version and patch releases of Capistrano
lock '~> 3.19.2'

require 'active_support/encrypted_file'
require 'yaml'

YAML.load(
  ActiveSupport::EncryptedFile.new(
    content_path: './config/credentials.yml.enc',
    key_path: './config/master.key',
    env_key: 'development',
    raise_if_missing_key: true
  ).read
).slice(*%w[aws_ec2_ip aws_pem_key_location]).each { |k, v| set k.to_sym, v }

set :rvm_ruby_version, '3.4.1'
set :user, 'ubuntu'
server fetch(:aws_ec2_ip), port: 22, roles: %i[web app db], primary: true

set :default_env, { 'RAILS_MASTER_KEY' => File.read('./config/master.key').strip }
set :passenger_in_gemfile, true
set :passenger_restart_with_touch, true
set :passenger_restart_with_sudo, true

set :application, 'deal-notifier'
set :repo_url, 'git@github.com:kalmai/rails-deal-notifier.git'
set :branch, :main

set :pty, true
set :use_sudo, false
set :rails_env, 'production'

set :migration_role, :app
set :migration_servers, []
set :migration_command, 'db:migrate'
set :conditionally_migrate, true

set :assets_roles, %i[web app]
set :assets_prefix, 'prepackaged-assets'
set :assets_manifests, ['app/assets/config/manifest.js']
set :rails_assets_groups, :assets

set :keep_assets, 2

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "~/deploy/#{fetch(:application)}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, *%w(tmp/pids tmp/sockets log)

append :linked_files, "config/master.key"

namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app) do
        shared_path = '/home/ubuntu/deploy/deal-notifier/shared'
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end
end

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :ssh_options, { forward_agent: true, user: fetch(:user), keys: [fetch(:aws_pem_key_location)] }
