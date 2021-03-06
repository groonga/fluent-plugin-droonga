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
  def create_handler
    Droonga::Plugins::Groonga::TableCreate::Handler.new("droonga",
                                                        @handler.context,
                                                        @messenger,
                                                        @loop)
  end

  def test_success
    response = process(:table_create, {"name" => "Books"})
    assert_equal(
      [NORMALIZED_HEADER_SUCCESS, true],
      [normalize_header(response.first), response.last]
    )
  end

  def test_failure
    response = process(:table_create, {})
    assert_equal(
      [NORMALIZED_HEADER_INVALID_ARGUMENT, false],
      [normalize_header(response.first), response.last]
    )
  end

  def test_name
    process(:table_create, {"name" => "Books"})
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
      process(:table_create, request)
      assert_equal(data[:schema], dump)
    end
  end

  class KeyTypeTest < self
    def test_key_type
      request = {
        "name"  => "Books",
        "key_type" => "Int32",
      }
      process(:table_create, request)
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
      process(:table_create, request)
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
      process(:table_create, request)
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
      process(:table_create, request)
      assert_equal(<<-SCHEMA, dump)
table_create Books TABLE_HASH_KEY --key_type ShortText --normalizer NormalizerAuto
      SCHEMA
    end
  end
end
