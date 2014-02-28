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

require "droonga/loggable"
require "droonga/dispatcher"

module Droonga
  class Engine
    include Loggable

    def initialize(catalog, options={})
      @catalog = catalog
      @options = options
      @dispatcher = Dispatcher.new(@catalog, @options)
    end

    def start
      @dispatcher.start
    end

    def shutdown
      logger.trace("shutdown: start")
      @dispatcher.shutdown
      logger.trace("shutdown: done")
    end

    def process(message)
      @dispatcher.process_message(message)
    end

    private
    def log_tag
      "engine"
    end
  end
end
