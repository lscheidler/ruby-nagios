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
              critical 'uhoh'
            elsif value > 2
              warning 'uhoh'
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

  describe Nagios::Expectations do
    before(:all) do
      class TestPlugin < Nagios::Plugin
        def initialize method:, value:, max: nil, msg: nil, status: :critical, warning_level: nil, critical_level: nil, with_perfdata: true
          super() do
            @with_perfdata = with_perfdata

            case method
            when :expect_not_nil
              expect_not_nil 'name', value, msg: msg, status: status
            when :expect_not_empty
              expect_not_empty 'name', value, msg: msg, status: status
            when :expect_level
              expect_level 'name', value, msg: msg, warning_level: warning_level, critical_level: critical_level
            when :expect_percentage_level
              expect_percentage_level 'name', value, max, msg: msg, warning_level: warning_level, critical_level: critical_level
            end
          end
        end
      end
    end

    describe 'expect_not_nil' do
      it 'should return critical' do
        expect{TestPlugin.new method: :expect_not_nil, value: nil}.to exit_with_code(2).and output(/CRITICAL: critical\(name is nil\)/).to_stdout
      end

      it 'should return unknown' do
        expect{TestPlugin.new method: :expect_not_nil, value: nil, status: :unknown}.to exit_with_code(3).and output(/UNKNOWN: unknown\(name is nil\)/).to_stdout
      end

      it 'should return ok' do
        expect{TestPlugin.new method: :expect_not_nil, value: '', status: :unknown}.to exit_with_code(0).and output(/OK: Everything ok./).to_stdout
      end

      it 'should return message' do
        expect{TestPlugin.new method: :expect_not_nil, value: nil, msg: 'Hello World'}.to exit_with_code(2).and output(/CRITICAL: critical\(Hello World\)/).to_stdout
      end
    end

    describe 'expect_not_emtpy' do
      it 'should return critical' do
        expect{TestPlugin.new method: :expect_not_empty, value: []}.to exit_with_code(2).and output(/CRITICAL: critical\(name is empty\)/).to_stdout
      end

      it 'should return unknown' do
        expect{TestPlugin.new method: :expect_not_empty, value: [], status: :unknown}.to exit_with_code(3).and output(/UNKNOWN: unknown\(name is empty\)/).to_stdout
      end

      it 'should return ok' do
        expect{TestPlugin.new method: :expect_not_empty, value: [''], status: :unknown}.to exit_with_code(0).and output(/OK: Everything ok./).to_stdout
      end

      it 'should return message' do
        expect{TestPlugin.new method: :expect_not_empty, value: [], msg: 'Hello World'}.to exit_with_code(2).and output(/CRITICAL: critical\(Hello World\)/).to_stdout
      end
    end

    describe 'expect_level' do
      it 'should return critical' do
        expect{TestPlugin.new method: :expect_level, value: 100, warning_level: 50, critical_level: 99}.to exit_with_code(2).and output(/CRITICAL: critical\(name=100\) \| name=100/).to_stdout
      end

      it 'should return warning' do
        expect{TestPlugin.new method: :expect_level, value: 51, warning_level: 50, critical_level: 99}.to exit_with_code(1).and output(/WARNING: warning\(name=51\) \| name=51/).to_stdout
      end

      it 'should return warning' do
        expect{TestPlugin.new method: :expect_level, value: 99, warning_level: 50, critical_level: 99}.to exit_with_code(1).and output(/WARNING: warning\(name=99\) \| name=99/).to_stdout
      end

      it 'should return ok' do
        expect{TestPlugin.new method: :expect_level, value: 50, warning_level: 50, critical_level: 99}.to exit_with_code(0).and output(/OK: ok\(name=50\) \| name=50/).to_stdout
      end

      it 'should return ok with message' do
        expect{TestPlugin.new method: :expect_level, value: 50, warning_level: 50, critical_level: 99, msg: 'Hello World'}.to exit_with_code(0).and output(/OK: ok\(Hello World\) \| name=50/).to_stdout
      end

      it 'should return ok without perfdata' do
        expect{TestPlugin.new method: :expect_level, value: 50, warning_level: 50, critical_level: 99, with_perfdata: false}.to exit_with_code(0).and output(/OK: ok\(name=50\)$/).to_stdout
      end
    end

    describe 'expect_percentage_level' do
      it 'should return critical' do
        expect{TestPlugin.new method: :expect_percentage_level, value: 91, max: 100, warning_level: 50, critical_level: 90}.to exit_with_code(2).and output(/CRITICAL: critical\(name=91\.00%\) \| name=91\.00/).to_stdout
      end

      it 'should return warning' do
        expect{TestPlugin.new method: :expect_percentage_level, value: 51, max: 100, warning_level: 50, critical_level: 90}.to exit_with_code(1).and output(/WARNING: warning\(name=51\.00%\) \| name=51\.00/).to_stdout
      end

      it 'should return warning' do
        expect{TestPlugin.new method: :expect_percentage_level, value: 90, max: 100, warning_level: 50, critical_level: 90}.to exit_with_code(1).and output(/WARNING: warning\(name=90\.00%\) \| name=90\.00/).to_stdout
      end

      it 'should return ok' do
        expect{TestPlugin.new method: :expect_percentage_level, value: 50, max: 100, warning_level: 50, critical_level: 90}.to exit_with_code(0).and output(/OK: ok\(name=50\.00%\) \| name=50\.00/).to_stdout
      end

      it 'should return ok with message' do
        expect{TestPlugin.new method: :expect_percentage_level, value: 50, max: 100, warning_level: 50, critical_level: 90, msg: 'Hello World'}.to exit_with_code(0).and output(/OK: ok\(Hello World\) \| name=50\.00/).to_stdout
      end

      it 'should return ok without perfdata' do
        expect{TestPlugin.new method: :expect_percentage_level, value: 50, max: 100, warning_level: 50, critical_level: 90, with_perfdata: false}.to exit_with_code(0).and output(/OK: ok\(name=50\.00%\)$/).to_stdout
      end
    end
  end
end
