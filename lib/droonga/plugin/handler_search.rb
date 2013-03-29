# -*- coding: utf-8 -*-
#
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

require "tsort"
require "groonga"

require "droonga/handler"

module Droonga
  class SearchHandler < Droonga::Handler
    Droonga::HandlerPlugin.register("search", self)

    command :search
    def search(request)
      queries = request["queries"]
      results = {}
      outputs = {}
      query_sorter = QuerySorter.new
      queries.each do |name, query|
        query_sorter.add(name, [query["source"]])
      end
      query_sorter.tsort.each do |name|
        if queries[name]
          search_query(name, queries, results, outputs)
        elsif @context[name]
          results[name] = @context[name]
        else
          raise "undefined source(#{name}) was assigned"
        end
      end
      outputs
    end

    def search_query(name, queries, results, outputs)
      start_time = Time.now
      query = queries[name]
      source = results[query["source"]]
      if query["output"]
        offset = query["offset"] || 0
        limit = query["limit"] || 10
        columns = source.columns
        attributes = columns.collect do |column|
          {
            "name" => column.local_name,
            "type" => column.range.name,
            "vector" => column.vector?,
          }
        end
        column_names = columns.collect(&:local_name)
        records = source.open_cursor(:offset => offset,
                                     :limit => limit) do |cursor|
          cursor.collect do |record|
            column_names.collect do |name|
              record[name]
            end
          end
        end
        elapsed_time = Time.now.to_f - start_time.to_f
        outputs[name] = {
          "count" => source.size,
          "startTime" => start_time.iso8601,
          "elapsedTime" => elapsed_time,
          "attributes" => attributes,
          "records" => records,
        }
      end
    end

    class QuerySorter
      include TSort
      def initialize()
        @queries = {}
      end

      def add(name, sources=[])
        @queries[name] = sources
      end

      def tsort_each_node(&block)
        @queries.each_key(&block)
      end

      def tsort_each_child(node, &block)
        if @queries[node]
          @queries[node].each(&block)
        end
      end
    end
  end
end