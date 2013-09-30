# Copyright (C) 2013 droonga project
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

source "https://rubygems.org"

gemspec

local_rroonga_path = File.join(File.dirname(__FILE__), "..", "rroonga")
local_groonga_command_parser_path = File.join(File.dirname(__FILE__), "..", "groonga-command-parser")
if File.exist?(local_rroonga_path)
  gem "rroonga", :path => local_rroonga_path
  gem "groonga-command-parser", :path => local_groonga_command_parser_path
elsif ENV["TRAVIS"] == "true"
  gem "rroonga", :git => "git://github.com/ranguba/rroonga.git"
  gem "groonga-command-parser", :git => "git://github.com/groonga/groonga-command-parser.git"
end
