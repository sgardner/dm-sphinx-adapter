require File.join(File.dirname(__FILE__), 'helper')

class TestAdapter < Test::Unit::TestCase
  context 'DM::A::Sphinx::Adapter' do
    setup do
      load File.join(File.dirname(__FILE__), 'files', 'model.rb')
      @it       = repository(:search)
      @resource = Item
    end

    context 'class' do
      should 'use default field naming convention' do
        assert_equal(
          DataMapper::NamingConventions::Field::Underscored,
          @it.adapter.field_naming_convention
        )
      end

      should 'use default resource naming convention' do
        assert_equal(
          DataMapper::NamingConventions::Resource::UnderscoredAndPluralized,
          @it.adapter.resource_naming_convention
        )
      end
    end

    context '#read_many' do
      context 'conditions' do
        should 'return all objects when nil' do
          assert_equal [1, 2, 3], @it.read_many(query).map{|d| d[:id]}
        end

        should 'return subset of objects for conditions' do
          assert_equal [2], @it.read_many(query(:t_string => 'two')).map{|d| d[:id]}
        end
      end

      context 'offsets' do
        should 'be able to offset the objects' do
          assert_equal [1, 2, 3], @it.read_many(query(:offset => 0)).map{|d| d[:id]}
          assert_equal [2, 3], @it.read_many(query(:offset => 1)).map{|d| d[:id]}
          assert_equal [], @it.read_many(query(:offset => 3))
        end
      end

      context 'limits' do
        should 'be able to limit the objects' do
          assert_equal [1], @it.read_many(query(:limit => 1)).map{|d| d[:id]}
          assert_equal [1, 2], @it.read_many(query(:limit => 2)).map{|d| d[:id]}
        end
      end
    end

    context '#read_one' do
      should 'return the first object of a #read_many' do
        assert_equal @it.read_many(query).first, @it.read_one(query)

        query = query(:t_string => 'two')
        assert_equal @it.read_many(query).first, @it.read_one(query)
      end
    end
  end

  protected
    def query(conditions = {})
      DataMapper::Query.new(repository(:search), @resource, conditions)
    end
end
