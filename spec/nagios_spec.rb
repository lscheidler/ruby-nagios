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

require "spec_helper"

describe Nagios do
  it "has a version number" do
    expect(Nagios::VERSION).not_to be nil
  end

  describe Nagios::Plugin do
    before(:all) do
      class TestPlugin < Nagios::Plugin
        def initialize value
          super() do
            if value > 100
              raise
            elsif value > 5
              critical
            elsif value > 2
              warning
            end
          end
        end
      end
    end

    it "should be ok." do
      expect{TestPlugin.new 0}.to exit_with_code(0).and output(/OK: /).to_stdout
      expect{TestPlugin.new 2}.to exit_with_code(0).and output(/OK: /).to_stdout
    end

    it "should be warning." do
      expect{TestPlugin.new 3}.to exit_with_code(1).and output(/WARNING: /).to_stdout
      expect{TestPlugin.new 5}.to exit_with_code(1).and output(/WARNING: /).to_stdout
    end

    it "should be critical." do
      expect{TestPlugin.new 6}.to exit_with_code(2).and output(/CRITICAL: /).to_stdout
    end

    it "should be unknown." do
      expect{TestPlugin.new 101}.to exit_with_code(3).and output(/UNKNOWN: /).to_stdout
    end
  end
end
