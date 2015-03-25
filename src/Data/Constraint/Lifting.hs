{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# OPTIONS_GHC -fno-warn-deprecations #-}
module Data.Constraint.Lifting 
  ( Lifting(..)
  , Lifting2(..)
  ) where

import Control.Applicative
import Control.DeepSeq
import Control.Monad
import Control.Monad.Fix
import Control.Monad.IO.Class
import Control.Monad.Trans.Cont
import Control.Monad.Trans.Error
import Control.Monad.Trans.Except
import Control.Monad.Trans.Identity
import Control.Monad.Trans.List
import Control.Monad.Trans.Reader
import Control.Monad.Trans.State.Strict as Strict
import Control.Monad.Trans.State.Lazy as Lazy
import Control.Monad.Trans.Writer.Lazy as Lazy
import Control.Monad.Trans.Writer.Strict as Strict
import Data.Binary
import Data.Complex
import Data.Constraint
import Data.Foldable
import Data.Functor.Classes
import Data.Functor.Compose as Functor
import Data.Functor.Product as Functor
import Data.Functor.Sum as Functor
import Data.Hashable
import Data.Monoid
import Data.Ratio
import Data.Traversable
import GHC.Arr

class Lifting p f where
  lifting :: p a :- p (f a)
  default lifting :: (Lifting2 p q, p b, f ~ q b) => p a :- p (f a)
  lifting = liftingDefault

liftingDefault :: forall p q a b. (Lifting2 p q, p a) => p b :- p (q a b)
liftingDefault = Sub $ case lifting2 :: (p a, p b) :- p (q a b) of
  Sub Dict -> Dict

instance Lifting Eq [] where lifting = Sub Dict
instance Lifting Ord [] where lifting = Sub Dict
instance Lifting Show [] where lifting = Sub Dict
instance Lifting Read [] where lifting = Sub Dict
instance Lifting Hashable [] where lifting = Sub Dict
instance Lifting Binary [] where lifting = Sub Dict
instance Lifting NFData [] where lifting = Sub Dict

instance Lifting Eq Maybe where lifting = Sub Dict
instance Lifting Ord Maybe where lifting = Sub Dict
instance Lifting Show Maybe where lifting = Sub Dict
instance Lifting Read Maybe where lifting = Sub Dict
instance Lifting Hashable Maybe where lifting = Sub Dict
instance Lifting Binary Maybe where lifting = Sub Dict
instance Lifting NFData Maybe where lifting = Sub Dict
instance Lifting Monoid Maybe where lifting = Sub Dict

instance Lifting Eq Ratio where lifting = Sub Dict
-- instance Lifting Show Ratio where lifting = Sub Dict -- requires 7.10

instance Lifting Eq Complex where lifting = Sub Dict
instance Lifting Read Complex where lifting = Sub Dict
instance Lifting Show Complex where lifting = Sub Dict

instance Lifting Monoid ((->) a) where lifting = Sub Dict

instance Eq a => Lifting Eq (Either a)
instance Ord a => Lifting Ord (Either a)
instance Show a => Lifting Show (Either a)
instance Read a => Lifting Read (Either a)
instance Hashable a => Lifting Hashable (Either a)
instance Binary a => Lifting Binary (Either a)
instance NFData a => Lifting NFData (Either a)

instance Eq a => Lifting Eq ((,) a)
instance Ord a => Lifting Ord ((,) a)
instance Show a => Lifting Show ((,) a)
instance Read a => Lifting Read ((,) a)
instance Hashable a => Lifting Hashable ((,) a)
instance Binary a => Lifting Binary ((,) a)
instance NFData a => Lifting NFData ((,) a)
instance Monoid a => Lifting Monoid ((,) a)
instance Bounded a => Lifting Bounded ((,) a)
instance Ix a => Lifting Ix ((,) a)

instance Functor f => Lifting Functor (Compose f)
instance Foldable f => Lifting Foldable (Compose f)
instance Traversable f => Lifting Traversable (Compose f)
instance Applicative f => Lifting Applicative (Compose f)
instance Alternative f => Lifting Alternative (Compose f) where lifting = Sub Dict -- overconstrained
instance (Functor f, Show1 f) => Lifting Show1 (Compose f) where lifting = Sub Dict
instance (Functor f, Eq1 f) => Lifting Eq1 (Compose f) where lifting = Sub Dict
instance (Functor f, Ord1 f) => Lifting Ord1 (Compose f) where lifting = Sub Dict
instance (Functor f, Read1 f) => Lifting Read1 (Compose f) where lifting = Sub Dict
instance (Functor f, Eq1 f, Eq1 g) => Lifting Eq (Compose f g) where lifting = Sub Dict
instance (Functor f, Ord1 f, Ord1 g) => Lifting Ord (Compose f g) where lifting = Sub Dict
instance (Functor f, Read1 f, Read1 g) => Lifting Read (Compose f g) where lifting = Sub Dict
instance (Functor f, Show1 f, Show1 g) => Lifting Show (Compose f g) where lifting = Sub Dict

instance Functor f => Lifting Functor (Functor.Product f)
instance Foldable f => Lifting Foldable (Functor.Product f)
instance Traversable f => Lifting Traversable (Functor.Product f)
instance Applicative f => Lifting Applicative (Functor.Product f)
instance Alternative f => Lifting Alternative (Functor.Product f)
instance Monad f => Lifting Monad (Functor.Product f)
instance MonadFix f => Lifting MonadFix (Functor.Product f)
instance MonadPlus f => Lifting MonadPlus (Functor.Product f)
instance Show1 f => Lifting Show1 (Functor.Product f)
instance Eq1 f => Lifting Eq1 (Functor.Product f)
instance Ord1 f => Lifting Ord1 (Functor.Product f)
instance Read1 f => Lifting Read1 (Functor.Product f)
instance (Eq1 f, Eq1 g) => Lifting Eq (Functor.Product f g) where lifting = Sub Dict
instance (Ord1 f, Ord1 g) => Lifting Ord (Functor.Product f g) where lifting = Sub Dict
instance (Read1 f, Read1 g) => Lifting Read (Functor.Product f g) where lifting = Sub Dict
instance (Show1 f, Show1 g) => Lifting Show (Functor.Product f g) where lifting = Sub Dict

instance Functor f => Lifting Functor (Functor.Sum f)
instance Foldable f => Lifting Foldable (Functor.Sum f)
instance Traversable f => Lifting Traversable (Functor.Sum f)
instance Show1 f => Lifting Show1 (Functor.Sum f)
instance Eq1 f => Lifting Eq1 (Functor.Sum f)
instance Ord1 f => Lifting Ord1 (Functor.Sum f)
instance Read1 f => Lifting Read1 (Functor.Sum f)
instance (Eq1 f, Eq1 g) => Lifting Eq (Functor.Sum f g) where lifting = Sub Dict
instance (Ord1 f, Ord1 g) => Lifting Ord (Functor.Sum f g) where lifting = Sub Dict
instance (Read1 f, Read1 g) => Lifting Read (Functor.Sum f g) where lifting = Sub Dict
instance (Show1 f, Show1 g) => Lifting Show (Functor.Sum f g) where lifting = Sub Dict

instance Lifting Functor (Strict.StateT s) where lifting = Sub Dict
instance Lifting Monad (Strict.StateT s) where lifting = Sub Dict
instance Lifting MonadFix (Strict.StateT s) where lifting = Sub Dict
instance Lifting MonadIO (Strict.StateT s) where lifting = Sub Dict
instance Lifting MonadPlus (Strict.StateT s) where lifting = Sub Dict

instance Lifting Functor (Lazy.StateT s) where lifting = Sub Dict
instance Lifting Monad (Lazy.StateT s) where lifting = Sub Dict
instance Lifting MonadFix (Lazy.StateT s) where lifting = Sub Dict
instance Lifting MonadIO (Lazy.StateT s) where lifting = Sub Dict
instance Lifting MonadPlus (Lazy.StateT s) where lifting = Sub Dict

instance Lifting Functor (ReaderT e) where lifting = Sub Dict
instance Lifting Applicative (ReaderT e) where lifting = Sub Dict
instance Lifting Alternative (ReaderT e) where lifting = Sub Dict
instance Lifting Monad (ReaderT e) where lifting = Sub Dict
instance Lifting MonadPlus (ReaderT e) where lifting = Sub Dict
instance Lifting MonadFix (ReaderT e) where lifting = Sub Dict
instance Lifting MonadIO (ReaderT e) where lifting = Sub Dict

instance Lifting Functor (ErrorT e) where lifting = Sub Dict
instance Lifting Foldable (ErrorT e) where lifting = Sub Dict
instance Lifting Traversable (ErrorT e) where lifting = Sub Dict
instance Error e => Lifting Monad (ErrorT e) where lifting = Sub Dict
instance Error e => Lifting MonadFix (ErrorT e) where lifting = Sub Dict
instance Error e => Lifting MonadPlus (ErrorT e) where lifting = Sub Dict -- overconstrained!
instance Error e => Lifting MonadIO (ErrorT e) where lifting = Sub Dict
instance Show e => Lifting Show1 (ErrorT e) where lifting = Sub Dict
instance Eq e => Lifting Eq1 (ErrorT e) where lifting = Sub Dict
instance Ord e => Lifting Ord1 (ErrorT e) where lifting = Sub Dict
instance Read e => Lifting Read1 (ErrorT e) where lifting = Sub Dict
instance (Show e, Show1 m) => Lifting Show (ErrorT e m) where lifting = Sub Dict
instance (Eq e, Eq1 m) => Lifting Eq (ErrorT e m) where lifting = Sub Dict
instance (Ord e, Ord1 m) => Lifting Ord (ErrorT e m) where lifting = Sub Dict
instance (Read e, Read1 m) => Lifting Read (ErrorT e m) where lifting = Sub Dict

instance Lifting Functor (ExceptT e) where lifting = Sub Dict
instance Lifting Foldable (ExceptT e) where lifting = Sub Dict
instance Lifting Traversable (ExceptT e) where lifting = Sub Dict
instance Lifting Monad (ExceptT e) where lifting = Sub Dict
instance Lifting MonadFix (ExceptT e) where lifting = Sub Dict
instance Monoid e => Lifting MonadPlus (ExceptT e) where lifting = Sub Dict -- overconstrained!
instance Lifting MonadIO (ExceptT e) where lifting = Sub Dict
instance Show e => Lifting Show1 (ExceptT e) where lifting = Sub Dict
instance Eq e => Lifting Eq1 (ExceptT e) where lifting = Sub Dict
instance Ord e => Lifting Ord1 (ExceptT e) where lifting = Sub Dict
instance Read e => Lifting Read1 (ExceptT e) where lifting = Sub Dict
instance (Show e, Show1 m) => Lifting Show (ExceptT e m) where lifting = Sub Dict
instance (Eq e, Eq1 m) => Lifting Eq (ExceptT e m) where lifting = Sub Dict
instance (Ord e, Ord1 m) => Lifting Ord (ExceptT e m) where lifting = Sub Dict
instance (Read e, Read1 m) => Lifting Read (ExceptT e m) where lifting = Sub Dict

instance Lifting Functor (Strict.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting Applicative (Strict.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting Alternative (Strict.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting Monad (Strict.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting MonadFix (Strict.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting MonadPlus (Strict.WriterT w) where lifting = Sub Dict
instance Lifting Foldable (Strict.WriterT w) where lifting = Sub Dict
instance Lifting Traversable (Strict.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting MonadIO (Strict.WriterT w) where lifting = Sub Dict
instance Show w => Lifting Show1 (Strict.WriterT w) where lifting = Sub Dict
instance Eq w => Lifting Eq1 (Strict.WriterT w) where lifting = Sub Dict
instance Ord w => Lifting Ord1 (Strict.WriterT w) where lifting = Sub Dict
instance Read w => Lifting Read1 (Strict.WriterT w) where lifting = Sub Dict
instance (Show w, Show1 m) => Lifting Show (Strict.WriterT w m) where lifting = Sub Dict
instance (Eq w, Eq1 m) => Lifting Eq (Strict.WriterT w m) where lifting = Sub Dict
instance (Ord w, Ord1 m) => Lifting Ord (Strict.WriterT w m) where lifting = Sub Dict
instance (Read w, Read1 m) => Lifting Read (Strict.WriterT w m) where lifting = Sub Dict

instance Lifting Functor (Lazy.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting Applicative (Lazy.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting Alternative (Lazy.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting Monad (Lazy.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting MonadFix (Lazy.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting MonadPlus (Lazy.WriterT w) where lifting = Sub Dict
instance Lifting Foldable (Lazy.WriterT w) where lifting = Sub Dict
instance Lifting Traversable (Lazy.WriterT w) where lifting = Sub Dict
instance Monoid w => Lifting MonadIO (Lazy.WriterT w) where lifting = Sub Dict
instance Show w => Lifting Show1 (Lazy.WriterT w) where lifting = Sub Dict
instance Eq w => Lifting Eq1 (Lazy.WriterT w) where lifting = Sub Dict
instance Ord w => Lifting Ord1 (Lazy.WriterT w) where lifting = Sub Dict
instance Read w => Lifting Read1 (Lazy.WriterT w) where lifting = Sub Dict
instance (Show w, Show1 m) => Lifting Show (Lazy.WriterT w m) where lifting = Sub Dict
instance (Eq w, Eq1 m) => Lifting Eq (Lazy.WriterT w m) where lifting = Sub Dict
instance (Ord w, Ord1 m) => Lifting Ord (Lazy.WriterT w m) where lifting = Sub Dict
instance (Read w, Read1 m) => Lifting Read (Lazy.WriterT w m) where lifting = Sub Dict

instance Lifting Functor (ContT r) where lifting = Sub Dict -- overconstrained
instance Lifting Applicative (ContT r) where lifting = Sub Dict -- overconstrained
instance Lifting Monad (ContT r) where lifting = Sub Dict -- overconstrained
instance Lifting MonadIO (ContT r) where lifting = Sub Dict

instance Lifting Functor IdentityT where lifting = Sub Dict
instance Lifting Applicative IdentityT where lifting = Sub Dict
instance Lifting Alternative IdentityT where lifting = Sub Dict
instance Lifting Monad IdentityT where lifting = Sub Dict
instance Lifting MonadPlus IdentityT where lifting = Sub Dict
instance Lifting MonadFix IdentityT where lifting = Sub Dict
instance Lifting Foldable IdentityT where lifting = Sub Dict
instance Lifting Traversable IdentityT where lifting = Sub Dict
instance Lifting MonadIO IdentityT where lifting = Sub Dict
instance Lifting Show1 IdentityT where lifting = Sub Dict
instance Lifting Read1 IdentityT where lifting = Sub Dict
instance Lifting Ord1 IdentityT where lifting = Sub Dict
instance Lifting Eq1 IdentityT where lifting = Sub Dict
instance Show1 m => Lifting Show (IdentityT m) where lifting = Sub Dict
instance Read1 m => Lifting Read (IdentityT m) where lifting = Sub Dict
instance Ord1 m => Lifting Ord (IdentityT m) where lifting = Sub Dict
instance Eq1 m => Lifting Eq (IdentityT m) where lifting = Sub Dict

instance Lifting Functor ListT where lifting = Sub Dict
instance Lifting Applicative ListT where lifting = Sub Dict
instance Lifting Alternative ListT where lifting = Sub Dict -- overconstrained
instance Lifting Monad ListT where lifting = Sub Dict
instance Lifting MonadPlus ListT where lifting = Sub Dict -- overconstrained
instance Lifting Foldable ListT where lifting = Sub Dict
instance Lifting Traversable ListT where lifting = Sub Dict
instance Lifting MonadIO ListT where lifting = Sub Dict
instance Lifting Show1 ListT where lifting = Sub Dict
instance Lifting Read1 ListT where lifting = Sub Dict
instance Lifting Ord1 ListT where lifting = Sub Dict
instance Lifting Eq1 ListT where lifting = Sub Dict
instance Show1 m => Lifting Show (ListT m) where lifting = Sub Dict
instance Read1 m => Lifting Read (ListT m) where lifting = Sub Dict
instance Ord1 m => Lifting Ord (ListT m) where lifting = Sub Dict
instance Eq1 m => Lifting Eq (ListT m) where lifting = Sub Dict

class Lifting2 p f where
  lifting2 :: (p a, p b) :- p (f a b)

instance Lifting2 Eq Either where lifting2 = Sub Dict
instance Lifting2 Ord Either where lifting2 = Sub Dict
instance Lifting2 Show Either where lifting2 = Sub Dict
instance Lifting2 Read Either where lifting2 = Sub Dict
instance Lifting2 Hashable Either where lifting2 = Sub Dict
instance Lifting2 Binary Either where lifting2 = Sub Dict
instance Lifting2 NFData Either where lifting2 = Sub Dict

instance Lifting2 Eq (,) where lifting2 = Sub Dict
instance Lifting2 Ord (,) where lifting2 = Sub Dict
instance Lifting2 Show (,) where lifting2 = Sub Dict
instance Lifting2 Read (,) where lifting2 = Sub Dict
instance Lifting2 Hashable (,) where lifting2 = Sub Dict
instance Lifting2 Binary (,) where lifting2 = Sub Dict
instance Lifting2 NFData (,) where lifting2 = Sub Dict
instance Lifting2 Monoid (,) where lifting2 = Sub Dict
instance Lifting2 Bounded (,) where lifting2 = Sub Dict
instance Lifting2 Ix (,) where lifting2 = Sub Dict

instance Lifting2 Functor Compose where lifting2 = Sub Dict
instance Lifting2 Foldable Compose where lifting2 = Sub Dict
instance Lifting2 Traversable Compose where lifting2 = Sub Dict
instance Lifting2 Applicative Compose where lifting2 = Sub Dict
instance Lifting2 Alternative Compose where lifting2 = Sub Dict -- overconstrained

instance Lifting2 Functor Functor.Product where lifting2 = Sub Dict
instance Lifting2 Foldable Functor.Product where lifting2 = Sub Dict
instance Lifting2 Traversable Functor.Product where lifting2 = Sub Dict
instance Lifting2 Applicative Functor.Product where lifting2 = Sub Dict
instance Lifting2 Alternative Functor.Product where lifting2 = Sub Dict
instance Lifting2 Monad Functor.Product where lifting2 = Sub Dict
instance Lifting2 MonadPlus Functor.Product where lifting2 = Sub Dict
instance Lifting2 MonadFix Functor.Product where lifting2 = Sub Dict
instance Lifting2 Show1 Functor.Product where lifting2 = Sub Dict
instance Lifting2 Eq1 Functor.Product where lifting2 = Sub Dict
instance Lifting2 Ord1 Functor.Product where lifting2 = Sub Dict
instance Lifting2 Read1 Functor.Product where lifting2 = Sub Dict

instance Lifting2 Functor Functor.Sum where lifting2 = Sub Dict
instance Lifting2 Foldable Functor.Sum where lifting2 = Sub Dict
instance Lifting2 Traversable Functor.Sum where lifting2 = Sub Dict
instance Lifting2 Show1 Functor.Sum where lifting2 = Sub Dict
instance Lifting2 Eq1 Functor.Sum where lifting2 = Sub Dict
instance Lifting2 Ord1 Functor.Sum where lifting2 = Sub Dict
instance Lifting2 Read1 Functor.Sum where lifting2 = Sub Dict
