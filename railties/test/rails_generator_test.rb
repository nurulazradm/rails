$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
RAILS_ROOT = File.dirname(__FILE__)

require 'test/unit'

require 'rails_generator'
require 'rails_generator/simple_logger'
Rails::Generator::Base.logger = Rails::Generator::SimpleLogger.new

begin
  require 'rubygems'
  require_gem 'actionpack'
rescue LoadError
end

class RailsGeneratorTest < Test::Unit::TestCase
  BUILTINS = %w(controller mailer model scaffold)
  CAPITALIZED_BUILTINS = BUILTINS.map { |b| b.capitalize }

  def test_lookup_builtins
    (BUILTINS + CAPITALIZED_BUILTINS).each do |name|
      assert_nothing_raised do
        spec = Rails::Generator::Base.lookup(name)
        assert_not_nil spec
        assert_kind_of Rails::Generator::Spec, spec

        klass = spec.klass
        assert klass < Rails::Generator::Base
        assert_equal spec, klass.spec
      end
    end
  end

  def test_autolookup
    assert_nothing_raised { ControllerGenerator }
    assert_nothing_raised { ModelGenerator }
  end

  def test_lookup_missing_generator
    assert_raise(LoadError) {
      Rails::Generator::Base.lookup('missing_generator').klass
    }
  end

  def test_lookup_missing_class
    spec = nil
    assert_nothing_raised { spec = Rails::Generator::Base.lookup('missing_class') }
    assert_not_nil spec
    assert_kind_of Rails::Generator::Spec, spec
    assert_raise(NameError) { spec.klass }
  end

  def test_generator_usage
    BUILTINS.each do |name|
      assert_raise(Rails::Generator::UsageError) {
        Rails::Generator::Base.instance(name)
      }
    end
  end

  def test_generator_spec
    spec = Rails::Generator::Base.lookup('working')
    assert_equal 'working', spec.name
    assert_equal "#{RAILS_ROOT}/script/generators/working", spec.path
    assert_equal :app, spec.source
    assert_nothing_raised { assert_match /WorkingGenerator$/, spec.klass.name }
  end

  def test_named_generator_attributes
    g = Rails::Generator::Base.instance('working', %w(admin/foo bar baz))
    assert_equal 'admin/foo', g.name
    assert_equal %w(admin), g.class_path
    assert_equal 'Admin', g.class_nesting
    assert_equal 'Foo', g.class_name
    assert_equal 'foo', g.singular_name
    assert_equal 'foos', g.plural_name
    assert_equal g.singular_name, g.file_name
    assert_equal g.plural_name, g.table_name
    assert_equal %w(bar baz), g.args
  end
end
