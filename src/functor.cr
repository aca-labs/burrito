module Functor(T)
  abstract def fmap(&block : T -> U) : Functor(U) forall U
end
