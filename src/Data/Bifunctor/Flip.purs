module Data.Bifunctor.Flip where

import Data.Bifoldable
import Data.Bifunctor
import Data.Bitraversable
import Data.Foldable
import Data.Traversable
import Data.Monoid
import Control.Apply
import Control.Biapply
-- Applicative is in Prelude
import Control.Biapplicative

data Flip p a b = Flip (p b a)

runFlip :: forall p a b. Flip p a b -> p b a
runFlip (Flip pba) = pba 

instance flipBifunctor :: (Bifunctor p) => Bifunctor (Flip p) where
  bimap f g = Flip <<< (bimap g f) <<< runFlip

instance flipFunctor :: (Bifunctor p) => Functor (Flip p a) where
  (<$>) f = Flip <<< lmap f <<< runFlip

instance flipBiapply :: (Biapply p) => Biapply (Flip p) where
  (<<*>>) (Flip fg) (Flip xy) = Flip (fg <<*>> xy)

instance flipBiapplicative :: (Biapplicative p) => Biapplicative (Flip p) where
  bipure a b = Flip (bipure b a)

instance flipBifoldable :: (Bifoldable p) => Bifoldable (Flip p) where
  bifoldr   f g z = bifoldr g f z <<< runFlip
  bifoldl   f g z = bifoldl g f z <<< runFlip
  bifoldMap f g   = bifoldMap g f <<< runFlip

instance flipFoldable :: (Bifoldable p) => Foldable (Flip p a) where
  foldr   f z = bifoldr   f   (flip const) z <<< runFlip
  foldl   f z = bifoldl   f         const  z <<< runFlip
  foldMap f   = bifoldMap f (const mempty)   <<< runFlip

instance flipBitraversable :: (Bitraversable p) => Bitraversable (Flip p) where
  bitraverse f g = (<$>) Flip <<< bitraverse g f <<< runFlip
  bisequence = bitraverse id id

instance flipTraversable :: (Bitraversable p) => Traversable (Flip p a) where
  traverse f = (<$>) Flip <<< bitraverse f pure <<< runFlip
  sequence = traverse id
