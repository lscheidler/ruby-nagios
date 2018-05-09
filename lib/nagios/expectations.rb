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

module Nagios
  # provides expect functions to check values
  module Expectations
    # @param name [String] name of value
    # @param value value to check
    # @param msg [String] message to set instead of default
    # @param status [Symbol] use *status*, if expect fails
    def expect_not_nil name, value, msg: nil, status: :critical
      if value.nil?
        msg = name + ' is nil' if msg.nil?
        send(status, msg)
      end
    end

    # @param name [String] name of value
    # @param array array to check
    # @param msg [String] message to set instead of default
    # @param status [Symbol] use *status*, if expect fails
    def expect_not_empty name, array, msg: nil, status: :critical
      if array.empty?
        msg = name + ' is empty' if msg.nil?
        send(status, msg)
      end
    end

    # @param name [String] name of value
    # @param value value to check
    # @param msg [String] message to set instead of default
    # @param warning_level [Fixnum] warning level
    # @param critical_level [Fixnum] critical level
    def expect_level name, value, msg: nil, warning_level: nil, critical_level: nil
      msg = name + '=' + value.to_s if msg.nil?
      @perfdata << name + '=' + value.to_s
      if critical_level and value > critical_level
        critical msg
      elsif warning_level and value > warning_level
        warning msg
      else
        ok msg
      end
    end

    # @param name [String] name of value
    # @param value value to check
    # @param max maximum value (e.g. value, which is equivalent to 100%)
    # @param msg [String] message to set instead of default
    # @param warning_level [Fixnum] warning level
    # @param critical_level [Fixnum] critical level
    def expect_percentage_level name, value, max, msg: nil, warning_level: nil, critical_level: nil
      percentage = value.to_f/max.to_f*100.0
      msg = sprintf "%s=%.2f%%", name, percentage if msg.nil?
      @perfdata << sprintf("%s=%.2f", name, percentage)
      if critical_level and percentage > critical_level
        critical msg
      elsif warning_level and percentage > warning_level
        warning msg
      else
        ok msg
      end
    end
  end
end
