require "./monad"

# The `Either` type represents values with two possibilities: a value of type
# Either a b is either Left a or Right b.
#
# The Either type is sometimes used to represent a value which is either correct
# or an error; by convention, the Left constructor is used to hold an error
# value and the Right constructor is used to hold a correct value (mnemonic:
# "right" also means "correct").
abstract struct Either(A, B)
  include Monad(B)

  # Creates a new `Either` by wrapping the passed value.
  def self.unit(x : B) : Right(B)
    Right.new x
  end

  # Extract the wrapped value.
  #
  # The value will be provided as a union of the Left and Right types. These may
  # then be parsed externally as required.
  def value : A | B
    @value
  end

  # Extract the wrapped value, throwing an exception if the instance is a Left.
  abstract def value! : B

  # Extract the wrapped value, or return nil in the case of a Left.
  abstract def value? : B?

  struct Left(T) < Either(T, Nil)
    def initialize(@value : T); end

    def value! : NoReturn
      {% if T <= Exception %}
        raise @value
      {% else %}
        raise "Error unwrapping value from #{self}: #{@value}"
      {% end %}
    end

    def value? : Nil
      nil
    end

    def fmap(&block : T -> _) : Left(T)
      self
    end

    def bind(&block : T -> _) : Left(T)
      self
    end
  end

  struct Right(T) < Either(Nil, T)
    def initialize(@value : T); end

    def value! : T
      @value
    end

    def value? : T
      @value
    end

    def fmap(&block : T -> U) : Right(U) forall U
      Either.unit block.call(@value)
    end

    def bind(&block : T -> Either(U, V)) : Either(U, V) forall U, V
      block.call @value
    end
  end
end
