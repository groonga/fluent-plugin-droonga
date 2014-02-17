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

require "droonga/error"
require "droonga/status_code"

module Droonga
  class MessageProcessingError < Error
    STATUS_CODE = STATUS_INTERNAL_ERROR

    attr_reader :message, :detail

    def initialize(message, detail=nil)
      @message = message
      @detail = detail
    end

    def name
      self.class.name.split("::").last
    end

    def status_code
      self.class::STATUS_CODE
    end

    def response_body
      body = {
        "name"    => name,
        "message" => @message,
      }
      body["detail"] = @detail unless @detail.nil?
      body
    end
  end

  class BadRequest < MessageProcessingError
    STATUS_CODE = STATUS_BAD_REQUEST
  end

  class NotFound < MessageProcessingError
    STATUS_CODE = STATUS_NOT_FOUND
  end
end
