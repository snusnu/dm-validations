require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'
  
  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::ConfirmationValidator do
    before(:all) do
      class Canoe
        include DataMapper::Validate
        def name=(value)
          @name = value
        end
      
        def name
          @name ||= nil
        end
      
        def name_confirmation=(value)
          @name_confirmation = value
        end
      
        def name_confirmation
          @name_confirmation ||= nil
        end
      
        validates_confirmation_of :name
      end
    end
  
    it "should validate the confirmation of a value on an instance of a resource" do
      canoe = Canoe.new
      canoe.name = 'White Water'
      canoe.name_confirmation = 'Not confirmed'
      canoe.valid?.should_not == true    
      canoe.errors.full_messages.first.should == 'Name does not match the confirmation'
    
      canoe.name_confirmation = 'White Water'
      canoe.valid?.should == true
    end
  
    it "should default the name of the confirmation field to <field>_confirmation if one is not specified" do
      canoe = Canoe.new
      canoe.name = 'White Water'
      canoe.name_confirmation = 'White Water'
      canoe.valid?.should == true    
    end
  
    it "should default to allowing nil values on the fields if not specified to" do
      Canoe.new().valid?().should == true
    end
  
    it "should not pass validation with a nil value when specified to" do
      class Canoe
        validators.clear!
        validates_confirmation_of :name, :allow_nil => false
      end
      Canoe.new().valid?().should_not == true
    end
  
    it "should allow the name of the confirmation field to be set" do
      class Canoe
        validators.clear!
        validates_confirmation_of :name, :confirm => :name_check
        def name_check=(value)
          @name_check = value
        end
      
        def name_check
          @name_confirmation ||= nil
        end    
      end
      canoe = Canoe.new
      canoe.name = 'Float'
      canoe.name_check = 'Float'
      canoe.valid?.should == true
    
    end
  
  end
  
rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
