# Copyright 2018 Lars Eric Scheidler
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "nagios/version"

require "nagios/status"
require "nagios/expectations"

# nagios module for plugin development
module Nagios
  # basis class for nagios plugins
  class Plugin
    include Expectations

    # @yield block with check implementation
    def initialize
      set_defaults
      set_plugin_defaults

      begin
        yield
      rescue => exception
        msg = exception.class.to_s + ' ' + exception.message
        if @debug
          $stderr.puts exception.class.to_s + ' ' + exception.message
          $stderr.puts exception.backtrace.join("\n  ")
        end
        @unknown << msg
      end

      exit_with_msg
    end

    # set defaults
    def set_defaults
      ok
      @perfdata = []
      @with_perfdata = true

      @ok = Nagios::Status.new :ok, 0, default_message: 'Everything ok.'
      @warning = Nagios::Status.new :warning, 1
      @critical = Nagios::Status.new :critical, 2
      @unknown = Nagios::Status.new :unknown, 3
    end

    # set plugin defaults
    def set_plugin_defaults
    end

    # set status to ok
    def ok msg=nil
      @ok << msg unless msg.nil?
    end

    # set status to warning
    def warning msg
      @warning << msg
    end

    # set status to critical
    def critical msg
      @critical << msg
    end

    # set status to unknown
    def unknown msg=nil
      @unknown << msg unless msg.nil?
    end

    def failed?
      (not @warning.empty? or not @critical.empty? or not @unknown.empty?)
    end

    # exit nagios check with current status and corresponding status code
    def exit_with_msg
      msg = []
      status = @ok
      [ @ok, @warning, @critical, @unknown ].each do |level|
        if not level.empty?
          status = level
          msg.unshift level.name.to_s + '(' + level.messages.join(', ') + ')'
        end
      end

      msg = [@ok.default_message] if status == @ok and msg.empty?

      print status.name.to_s.upcase + ': ' + msg.join(' ')
      print ' | ' + @perfdata.join(' ') if @with_perfdata and not @perfdata.empty?
      puts
      exit status.code
    end
  end
end
