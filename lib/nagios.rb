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

# nagios module for plugin development
module Nagios
  # basis class for nagios plugins
  class Plugin
    # @yield block with check implementation
    def initialize
      set_defaults

      begin
        yield
      rescue => exception
        @msg = exception.class.to_s + ' ' + exception.message
        unknown
      end

      exit_with_msg
    end

    # set defaults
    def set_defaults
      ok
      @msg = 'Everything ok.'
      @perfdata = []
    end

    # set status to ok
    def ok
      @status = :ok
      @status_code = 0
    end

    # set status to warning
    def warning
      @status = :warning
      @status_code = 1
    end

    # set status to critical
    def critical
      @status = :critical
      @status_code = 2
    end

    # set status to unknown
    def unknown
      @status = :unknown
      @status_code = 3
    end

    # exit nagios check with current status and corresponding status code
    def exit_with_msg
      puts @status.to_s.upcase + ': ' + @msg.to_s
      exit @status_code
    end
  end
end
