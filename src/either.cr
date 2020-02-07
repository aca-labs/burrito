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
  def self.unit(x : B) : Either(Nil, B)
    Right(Nil, B).new x
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

  # Apply *a* if the instance is a Left, or *b* in the case of a right.
  abstract def fold(a : A -> T, b : B -> T) : T forall T

  struct Left(A, B) < Either(A, B)
    def initialize(@value : A); end

    def value! : NoReturn
      {% if A <= Exception %}
        raise @value
      {% else %}
        raise "Error unwrapping value from #{self}: #{@value}"
      {% end %}
    end

    def value? : Nil
      nil
    end

    def fmap(&block : B -> T) : Either(A, T) forall T
      Left(A, T).new @value
    end

    def bind(&block : B -> Either(T, U)) : Either(A, U) forall T, U
      Left(A, U).new @value
    end

    def fold(a : A -> T, b : B -> T) : T forall T
      a.call @value
    end
  end

  struct Right(A, B) < Either(A, B)
    def initialize(@value : B); end

    def value! : B
      @value
    end

    def value? : B
      @value
    end

    def fmap(&block : B -> T) : Either(A, T) forall T
      Right(A, T).new block.call(@value)
    end

    def bind(&block : B -> Either(T, U)) : Either(T, U) forall T, U
      block.call @value
    end

    def fold(a : A -> T, b : B -> T) : T forall A, T
      b.call @value
    end
  end
end
