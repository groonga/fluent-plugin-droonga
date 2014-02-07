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

require "tsort"

module Droonga
  class Distributor
    class UndefinedInputError < StandardError
      attr_reader :input
      def initialize(input)
        @input = input
        super("undefined input assigned: <#{input}>")
      end
    end

    class CyclicStepsError < StandardError
      attr_reader :steps
      def initialize(steps)
        @steps = steps
        super("cyclic steps found: <#{steps}>")
      end
    end

    include TSort

    def initialize(dispatcher)
      @dispatcher = dispatcher
    end

    def distribute(plan)
      @dependency = {}
      plan.each do |step|
        @dependency[step] = step["inputs"]
        next unless step["outputs"]
        step["outputs"].each do |output|
          @dependency[output] = [step]
        end
      end
      steps = []
      each_strongly_connected_component do |cs|
        raise CyclicStepsError.new(cs) if cs.size > 1
        steps.concat(cs) unless cs.first.is_a? String
      end
      @dispatcher.dispatch_steps(steps)
    end

    private
    def tsort_each_node(&block)
      @dependency.each_key(&block)
    end

    def tsort_each_child(node, &block)
      if node.is_a? String and @dependency[node].nil?
        raise UndefinedInputError.new(node)
      end
      if @dependency[node]
        @dependency[node].each(&block)
      end
    end
  end
end