require "spec_helper"

describe Referal::ConstraintType::StartWith do
  it "should validate string 'instedd office' start with 'instedd' without error " do
    startValidator = Referal::ConstraintType::StartWith.new "instedd"
    startValidator.validate('instedd office', "org").should eq true
    startValidator.errors.size.should eq 0
  end
  
  it "should validate string 'instedd. office' start with 'InSTEDD.' no case" do
    startValidator = Referal::ConstraintType::StartWith.new "InSTEDD." 
    startValidator.validate('instedd. office', "org").should eq true
    startValidator.errors.size.should eq 0
  end
  
  it "should validate string 'instedd. office' start with 'InSTEDD.' with eroor " do
    startValidator = Referal::ConstraintType::StartWith.new "InSTEDDx"
    startValidator.validate('instedd. office', "org").should eq false
    startValidator.errors.size.should eq 1
    startValidator.errors[0].should eq "Org: instedd. office should start with InSTEDDx"
  end
  
end
