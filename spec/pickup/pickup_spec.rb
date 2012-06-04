# encoding: utf-8
require 'spec_helper'

describe Pickup do
  before do
    @list = {
      "selmon"  => 1,     # 1
      "carp" => 4,        # 5
      "crucian"  => 3,    # 8
      "herring" => 6,     # 14
      "sturgeon" => 8,    # 22
      "gudgeon" => 10,    # 32
      "minnow" => 20      # 52
    }
    @func = Proc.new{ |a| a }
    @pickup = Pickup.new(@list)
    @pickup2 = Pickup.new(@list, uniq: true)
  end

  it "should pick correct ammount of items" do
    @pickup.pick(2).size.must_equal 2
    @pickup.pick(10).size.must_equal 10
  end

  describe Pickup::MappedList do
    before do
      @ml = Pickup::MappedList.new(@list, @func, true)
      @ml2 = Pickup::MappedList.new(@list, @func)
    end

    it "should return selmon and then carp and then crucian for uniq pickup" do
      @ml.get_random_items([0, 0, 0]).must_equal ["selmon", "carp", "crucian"]
    end

    it "should return selmon 3 times for non-uniq pickup" do
      @ml2.get_random_items([0]).first.must_equal "selmon"
      @ml2.get_random_items([0]).first.must_equal "selmon"
      @ml2.get_random_items([0]).first.must_equal "selmon"
    end

    it "should return crucian 3 times for uniq pickup" do
      @ml2.get_random_items([7, 7, 7]).must_equal ["crucian", "crucian", "crucian"]
    end

    it "should return item from the beginning after end of list for uniq pickup" do
      @ml.get_random_items([20, 20, 20, 20]).must_equal ["sturgeon", "gudgeon", "minnow", "crucian"]
    end

    it "should return right max" do
      @ml.max.must_equal 52
    end
  end

  it "should take 7 different fish" do
    items = @pickup2.pick(7)
    items.uniq.size.must_equal 7
  end

  it "should raise an exception" do
    proc{ items = @pickup2.pick(8) }.must_raise RuntimeError
  end

  it "should return include most weigtfull item (but not always - sometimes it will fail)" do
    items = @pickup2.pick(2){ |v| v**20 }
    (items.include? "minnow").must_equal true
  end

  it "should return include less weigtfull item (but not always - sometimes it will fail)" do
    items = @pickup2.pick(2){ |v| v**(-20) }
    (items.include? "selmon").must_equal true
  end
end