require 'test_helper'

class DataSourceTest < ActiveSupport::TestCase
  context "A DataType" do
    setup do
      @ds = Factory :data_source
    end
    
    context "scraping data" do
      setup do
        @ds.fetch
      end
      
      should "create locations and instruments which have been unknown" do
        location = Location.where(:name => 'Imamura Genkai Town', :data_source_id => @ds.id).first
        assert_not_nil location
        assert_equal @ds.id, location.data_source_id
        
        instrument = @ds.instrument
        assert_not_nil instrument
        assert_equal "Autogenerated", instrument.notes
        assert_equal location.id, instrument.location_id
        assert_includes location.instruments, instrument
        assert_equal 'nGy/h', instrument.data_type.name
      end
      
      should "create a new sample if the value is not nil" do
        location = Location.where(:name => 'Imamura Genkai Town', :data_source_id => @ds.id).first
        sample = location.samples.last
        assert_not_nil sample
        assert_equal 27.0, sample.value
        assert_equal location, sample.location
        assert_equal @ds.instrument, sample.instrument
      end
      
      should "not create a sample if the value is nil" do
        location = Location.where(:name => 'Kyoudomarisaki Karatsu City', :data_source_id => @ds.id).first
        assert_equal 0, location.samples.count
      end
      
      should "not run again within the same update_interval" do
        assert_equal false, @ds.fetch
      end
      
    end
    
    context "scraping the same data twice" do
      setup do
        assert_equal true, @ds.fetch
        @ds.fetched_at = Time.now - 2.hours
        assert_equal true, @ds.fetch
      end
      
      should "not create duplicate locations" do
        assert_equal 1, Location.where(:name => 'Imamura Genkai Town', :data_source_id => @ds.id).count
      end
      
      should "not create duplicate samples" do
        assert_equal 1, Location.where(:name => 'Imamura Genkai Town', :data_source_id => @ds.id).first.samples.count
      end
    end
    
    context "scraping new data" do
        setup do
          assert_equal true, @ds.fetch
          @ds.fetched_at = Time.now - 2.hours
          @ds.url = "#{Rails.root}/test/html/saga2.html"
          assert_equal true, @ds.fetch
        end
        
        should "not create duplicate locations" do
          assert_equal 1, Location.where(:name => 'Imamura Genkai Town', :data_source_id => @ds.id).count
        end
        
        should "create new samples" do
          samples = Location.where(:name => 'Imamura Genkai Town', :data_source_id => @ds.id).first.samples
          assert_equal 2, samples.length
          assert_equal 28.0, samples[1].value
        end
    end
  end
end