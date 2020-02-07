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

  left = Either::Left.new "oh noes!"
  right = Either::Right.new 42

  describe "#value" do
    it "provides the value as a union of left and right types" do
      left.value.should be_a(Union(String, Nil))
      right.value.should be_a(Union(Nil, Int32))
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
        failed_io = Either::Left.new IO::Error.new
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

  describe "#fmap" do
    context "when left" do
      it "returns itself" do
        left.fmap { "foo" }.should eq(left)
      end

      it "bypasses execution of the block" do
        left.fmap { raise "foo" }.should eq(left)
      end
    end

    context "when right" do
      it "applies the passed block to the wrapped value" do
        right.fmap(&.to_f).should be_a(Either::Right(Float64))
      end
    end
  end

  describe "#bind" do
    context "when left" do
      it "bypasses execution of the block" do
        left.bind { raise "foo" }.should eq(left)
      end
    end

    context "when right" do
      it "applies the passed block" do
        right.bind { |x| Either.unit(x.to_f) }.should be_a(Either::Right(Float64))
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
