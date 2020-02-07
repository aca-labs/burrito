require "./functor"

module Monad(T)
  include Functor(T)

  # Temp workaround until https://github.com/crystal-lang/crystal/issues/5956 is
  # resolved / implemented
  macro included
    {% verbatim do %}
      macro finished
        {% unless @type.class.has_method? :unit %}
          {% raise "`def self.unit(x : T) : self` must be implemented by #{@type}" %}
        {% end %}
      end
    {% end %}
  end
  # Inject a value into the monadic type.
  # abstract def self.unit(a : T) : self

  abstract def bind(&block : T -> Monad(U)) : Monad(U) forall U
end
