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

require "droonga/plugin/handler/watch"

class WatchHandlerTest < Test::Unit::TestCase
  include WatchHelper

  def setup
    setup_database
    setup_schema
    setup_plugin
  end

  def teardown
    teardown_plugin
    teardown_database
  end

  private
  def setup_plugin
    @handler = Droonga::Test::StubHandler.new
    @plugin = Droonga::WatchHandler.new(@handler)
  end

  def teardown_plugin
    @plugin = nil
  end

  public
  class SubscribeTest < self
    def test_subscribe
      request = {
        "route" => "localhost:23003/output",
        "condition" => "たいやき",
        "subscriber" => "localhost"
      }
      mock(@plugin).emit([true])
      @plugin.subscribe(request)

      assert_equal(
        ["localhost:23003/output"],
        actual_routes_for_query("たいやき")
      )
    end

    def test_subscribe_route_omitted_from_specified
      request = {
        "condition" => "たいやき",
        "subscriber" => "localhost"
      }
      @handler.envelope["from"] = "localhost:23004/output"
      mock(@plugin).emit([true])
      @plugin.subscribe(request)

      assert_equal(
        ["localhost:23004/output"],
        actual_routes_for_query("たいやき")
      )
    end

    def test_subscribe_both_route_and_from_specified
      request = {
        "condition" => "たいやき",
        "subscriber" => "localhost",
        "route" => "localhost:23003/output"
      }
      @handler.envelope["from"] = "localhost:23004/output"
      mock(@plugin).emit([true])
      @plugin.subscribe(request)

      assert_equal(
        ["localhost:23003/output"],
        actual_routes_for_query("たいやき")
      )
    end

    private
    def actual_routes_for_query(query)
      @handler.context["Subscriber"].select {|record|
        record[:subscriptions] =~ query.to_json
      }.map {|subscriber|
        subscriber.route.key
      }
    end
  end

  class UnsubscribeTest < self
    def setup
      super
      setup_subscription
    end

    def test_unsubscribe
      request = {
        "route" => "localhost:23003/output",
        "condition" => "たいやき",
        "subscriber" => "localhost"
      }
      mock(@plugin).emit([true])
      @plugin.unsubscribe(request)
    end

    private
    def setup_subscription
      request = {
        "route" => "localhost:23003/output",
        "condition" => "たいやき",
        "subscriber" => "localhost"
      }
      stub(@plugin).emit([true])
      @plugin.subscribe(request)
    end
  end

  class FeedTest < self
    def setup
      super
      setup_subscription
    end

    def test_feed_match
      request = {
        "targets" => {
          "text" => "たいやきおいしいです"
        }
      }
      @plugin.feed(request)
      assert_equal([
                     [request,
                       {
                         "to"   => "localhost:23003/output",
                         "type" => "watch.notification",
                       },
                     ],
                   ],
                   @handler.messages)
      assert_equal({ "to" => ["localhost"] }, @handler.envelope)
    end

    def test_feed_not_match
      request = {
        "targets" => {
          "text" => "たこやきおいしいです"
        }
      }
      @plugin.feed(request)
      assert_equal([], @handler.messages)
    end

    private
    def setup_subscription
      request = {
        "route" => "localhost:23003/output",
        "condition" => "たいやき",
        "subscriber" => "localhost"
      }
      stub(@plugin).emit([true])
      @plugin.subscribe(request)
    end
  end
end
