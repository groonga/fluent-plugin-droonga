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

class TableCreateTest < GroongaHandlerTest
  def test_success
    mock(@handler).emit([true])
    @handler.table_create({"name" => "Books"})
    assert_equal(
      [[Droonga::GroongaHandler::Status::SUCCESS, NORMALIZED_START_TIME, NORMALIZED_ELAPSED_TIME], true],
      [normalize_header(@worker.body.first), @worker.body.last]
    )
  end

  def test_failure
    mock(@handler).emit([false])
    @handler.table_create({})
    assert_equal(
      [[Droonga::GroongaHandler::Status::INVALID_ARGUMENT, NORMALIZED_START_TIME, NORMALIZED_ELAPSED_TIME], false],
      [normalize_header(@worker.body.first), @worker.body.last]
    )
  end

  def test_name
    mock(@handler).emit([true])
    @handler.table_create({"name" => "Books"})
    assert_equal(<<-SCHEMA, dump)
table_create Books TABLE_HASH_KEY --key_type ShortText
    SCHEMA
  end

  class FlagsTest < self
    data({
           "TABLE_NO_KEY" => {
             :flags => "TABLE_NO_KEY",
             :schema => <<-SCHEMA,
table_create Books TABLE_NO_KEY
             SCHEMA
           },
           "TABLE_HASH_KEY" => {
             :flags => "TABLE_HASH_KEY",
             :schema => <<-SCHEMA,
table_create Books TABLE_HASH_KEY --key_type ShortText
             SCHEMA
           },
           "TABLE_PAT_KEY" => {
             :flags => "TABLE_PAT_KEY",
             :schema => <<-SCHEMA,
table_create Books TABLE_PAT_KEY --key_type ShortText
             SCHEMA
           },
           "TABLE_DAT_KEY" => {
             :flags => "TABLE_DAT_KEY",
             :schema => <<-SCHEMA,
table_create Books TABLE_DAT_KEY --key_type ShortText
             SCHEMA
           },
           "KEY_WITH_SIS with TABLE_PAT_KEY" => {
             :flags => "KEY_WITH_SIS|TABLE_PAT_KEY",
             :schema => <<-SCHEMA,
table_create Books TABLE_PAT_KEY|KEY_WITH_SIS --key_type ShortText
             SCHEMA
           },
           "KEY_WITH_SIS without TABLE_PAT_KEY" => {
             :flags => "TABLE_NO_KEY|KEY_WITH_SIS",
             :schema => <<-SCHEMA,
table_create Books TABLE_NO_KEY
             SCHEMA
           },
         })
    def test_flags(data)
      request = {
        "name" => "Books",
        "flags" => data[:flags],
      }
      mock(@handler).emit([true])
      @handler.table_create(request)
      assert_equal(data[:schema], dump)
    end
  end

  class KeyTypeTest < self
    def test_key_type
      request = {
        "name"  => "Books",
        "key_type" => "Int32",
      }
      mock(@handler).emit([true])
      @handler.table_create(request)
      assert_equal(<<-SCHEMA, dump)
table_create Books TABLE_HASH_KEY --key_type Int32
      SCHEMA
    end
  end

  class ValueTypeTest < self
    def test_value_type
      request = {
        "name"  => "Books",
        "value_type" => "Int32",
      }
      mock(@handler).emit([true])
      @handler.table_create(request)
      assert_equal(<<-SCHEMA, dump)
table_create Books TABLE_HASH_KEY --key_type ShortText --value_type Int32
      SCHEMA
    end
  end

  class DefaultTokenizerTest < self
    def test_default_tokenizer
      request = {
        "name"  => "Books",
        "default_tokenizer" => "TokenBigram",
      }
      mock(@handler).emit([true])
      @handler.table_create(request)
      assert_equal(<<-SCHEMA, dump)
table_create Books TABLE_HASH_KEY --key_type ShortText --default_tokenizer TokenBigram
      SCHEMA
    end
  end

  class NormalizerTest < self
    def test_normalizer
      request = {
        "name"  => "Books",
        "normalizer" => "NormalizerAuto",
      }
      mock(@handler).emit([true])
      @handler.table_create(request)
      assert_equal(<<-SCHEMA, dump)
table_create Books TABLE_HASH_KEY|KEY_NORMALIZE --key_type ShortText
      SCHEMA
    end
  end
end
