# -*- ruby -*-
#
# Copyright (C) 2013-2014 Droonga Project
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

require "bundler/gem_helper"
require "packnga"

base_dir = File.join(File.dirname(__FILE__))

helper = Bundler::GemHelper.new(base_dir)
helper.install
spec = helper.gemspec

Packnga::DocumentTask.new(spec) do |task|
  task.original_language = "en"
  task.translate_languages = ["ja"]
end

def run_command_test(*options)
  ruby(File.join(File.dirname(__FILE__), "test", "command", "run-test.rb",),
       *options)
end

namespace :test do
  desc "Run unit test"
  task :unit do
    ruby(File.join(File.dirname(__FILE__), "test", "unit", "run-test.rb"))
  end

  namespace :command do
    desc "Run command test: default"
    task :default do
      run_command_test
    end

    desc "Run command test: version1"
    task :version1 do
      run_command_test("--config", "version1")
    end
  end
end

desc "Run test"
task :test => [
  "test:unit",
  "test:command:default",
  "test:command:version1",
]

test_task = ENV["DEFAULT_TEST_TASK"] || "test"
task :default => test_task
