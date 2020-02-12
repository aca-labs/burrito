require "./spec_helper"

describe Either do
  describe ".unit" do
    it "wraps a value in the correct abstractions" do
      x = Either.unit(42)
      x.should be_a(Either(Nil, Int32))
      x.should be_a(Monad(Int32))
      x.should be_a(Functor(Int32))
    end
  end

  describe ".left" do
    it "creates an Either::Left" do
      x = Either(String, Int32).left "testing"
      x.should be_a(Either(String, Int32))
      x.left?.should be_true
    end
  end

  describe ".right" do
    it "creates an Either::Right" do
      x = Either(String, Int32).right 42
      x.should be_a(Either(String, Int32))
      x.right?.should be_true
    end
  end

  left = Either(String, Int32).left "oh noes!"
  right = Either(String, Int32).right 42

  describe "#value" do
    it "provides the value as a union of left and right types" do
      left.value.should be_a(Union(String, Int32))
      right.value.should be_a(Union(String, Int32))
    end

    context "when instance is a Left" do
      it "provides the value left type" do
        left.value.should be_a(String)
      end
    end

    context "when instance is a Right" do
      it "provides the right type" do
        right.value.should be_a(Int32)
      end
    end
  end

  describe "#value!" do
    context "when left" do
      it "raises a base Exception for arbitrary types" do
        expect_raises(Exception) { left.value! }
      end

      it "raises custom exceptions if available" do
        failed_io = Either(IO::Error, Nil).left IO::Error.new
        expect_raises(IO::Error) { failed_io.value! }
      end
    end

    context "when right" do
      it "returns the unwrapped value" do
        right.value!.should eq(42)
        right.value!.should be_a(Int32)
      end
    end
  end

  describe "#value?" do
    context "when left" do
      it "returns nil" do
        left.value?.should be_nil
      end
    end

    context "when right" do
      it "returns the unwrapped" do
        right.value!.should eq(42)
        right.value!.should be_a(Int32)
      end
    end
  end

  describe "==" do
    l = ->(x : String) { Either(String, String).left x }
    r = ->(x : String) { Either(String, String).right x }

    (l.call("foo") == l.call("foo")).should be_true
    (r.call("foo") == r.call("foo")).should be_true
    (l.call("foo") == l.call("bar")).should be_false
    (r.call("foo") == r.call("bar")).should be_false
    (l.call("foo") == r.call("foo")).should be_false
    (r.call("foo") == l.call("foo")).should be_false
  end

  describe "#fmap" do
    context "when left" do
      it "applies the type associated with the block to the right side" do
        left.fmap { |_x| "foo" }.should be_a(Either(String, String))
      end

      it "bypasses execution of the block" do
        left.fmap { |_x| raise "foo" }.value.should eq(left.value)
      end
    end

    context "when right" do
      it "applies the passed block to the wrapped value" do
        right.fmap(&.to_f).value.should eq(right.value.to_f)
      end
    end
  end

  describe "#bind" do
    context "when left" do
      it "applies the type associated with the block" do
        left.bind { |_x| Either(Int32, String).right("foo") }.should be_a(Either(Int32 | String, String))
      end

      it "bypasses execution of the block" do
        left.bind { |_x| raise "foo"; Either.unit nil }.value.should eq(left.value)
      end
    end

    context "when right" do
      it "applies the type associated with the block" do
        right.bind { |_x| Either(Int32, String).right("foo") }.should be_a(Either(Int32 | String, String))
      end

      it "applies the passed block" do
        right.bind { |x| Either(Nil, Float64).right(x.to_f) }.value.should eq(right.value.to_f)
      end
    end
  end

  describe "#fold" do
    a = ->(_x : String) { "a" }
    b = ->(_x : Int32) { "b" }

    context "when left" do
      it "applies a" do
        left.fold(a, b).should eq("a")
      end
    end

    context "when right" do
      it "applies b" do
        right.fold(a, b).should eq("b")
      end
    end
  end
end
