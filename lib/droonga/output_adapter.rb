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

require "droonga/pluggable"
require "droonga/output_adapter_plugin"
require "droonga/output_message"

module Droonga
  class OutputAdapter
    include Pluggable

    def initialize(dispatcher, options={})
      @dispatcher = dispatcher
      load_plugins(options[:plugins] || [])
    end

    def adapt(message)
      adapted_message = message
      message["via"].reverse_each do |command|
        @plugins.each do |plugin|
          next unless plugin.processable?(command)
          output_message = OutputMessage.new(adapted_message)
          process(command, output_message)
          adapted_message = output_message.adapted_message
        end
      end
      adapted_message
    end

    private
    def instantiate_plugin(name)
      OutputAdapterPlugin.repository.instantiate(name, @dispatcher)
    end

    def log_tag
      "output-adapter"
    end
  end
end