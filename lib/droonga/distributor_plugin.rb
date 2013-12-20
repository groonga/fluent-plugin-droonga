# -*- coding: utf-8 -*-
#
# Copyright (C) 2013 Droonga Project
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

require "droonga/plugin"

module Droonga
  class DistributorPlugin < Plugin
    extend PluginRegisterable

    def initialize(distributor)
      super()
      @distributor = distributor
    end

    def distribute(message)
      @distributor.distribute(message)
    end

    def scatter_all(message, key)
      message = [{
        "command"=> message["type"],
        "dataset"=> message["dataset"],
        "body"=> message["body"],
        "key"=> key,
        "type"=> "scatter",
        "replica"=> "all",
        "post"=> true
      }]
      distribute(message)
    end

    def broadcast_all(message)
      distribute_message = [{
        "command"=> message["type"],
        "dataset"=> message["dataset"],
        "body"=> message["body"],
        "type"=> "broadcast",
        "replica"=> "all",
        "post"=> true
      }]
      distribute(distribute_message)
    end
  end
end
