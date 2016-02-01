{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}


module FrameworkHs.GenGrammars.L27UncoverFrameConflict where

import FrameworkHs.Prims
import FrameworkHs.Helpers
import Text.PrettyPrint.HughesPJ (text)
import Blaze.ByteString.Builder (fromByteString)

data Tail
  = IfT Pred Tail Tail
  | BeginT [Effect] Tail
  | AppT Triv [Var]
data Pred
  = TrueP
  | FalseP
  | IfP Pred Pred Pred
  | BeginP [Effect] Pred
  | AppP Relop Triv Triv
data Effect
  = Nop
  | IfE Pred Effect Effect
  | BeginE [Effect] Effect
  | Mset Triv Triv Triv
  | ReturnPoint Label Tail
  | Set1 Var Triv
  | Set2 Var Binop Triv Triv
  | Set3 Var Triv Triv
data Triv
  = Integer Integer
  | Label Label
  | Var Var
data Prog
  = Letrec [(Label,Body)] Body
data Loc
  = Reg Reg
  | FVarL FVar
data Var
  = UVarV UVar
  | Loc Loc
data Frame
  = AppF [UVar]
data Body
  = Locals [UVar] [Frame] [UVar] [(UVar,[Var])] [UFVar] Tail
data UFVar
  = UVarU UVar
  | FVarU FVar

instance PP Tail where
  pp (IfT p t t2) = (ppSexp [fromByteString "if",(pp p),(pp t),(pp t2)])
  pp (BeginT l t) = (ppSexp (fromByteString "begin" : ((map pp l) ++ [(pp t)])))
  pp (AppT t l) = (ppSexp ((pp t) : (map pp l)))
  ppp (IfT p t t2) = (pppSexp [text "if",(ppp p),(ppp t),(ppp t2)])
  ppp (BeginT l t) = (pppSexp (text "begin" : ((map ppp l) ++ [(ppp t)])))
  ppp (AppT t l) = (pppSexp ((ppp t) : (map ppp l)))
instance PP Pred where
  pp (TrueP) = (ppSexp [fromByteString "true"])
  pp (FalseP) = (ppSexp [fromByteString "false"])
  pp (IfP p p2 p3) = (ppSexp [fromByteString "if",(pp p),(pp p2),(pp p3)])
  pp (BeginP l p) = (ppSexp (fromByteString "begin" : ((map pp l) ++ [(pp p)])))
  pp (AppP r t t2) = (ppSexp [(pp r),(pp t),(pp t2)])
  ppp (TrueP) = (pppSexp [text "true"])
  ppp (FalseP) = (pppSexp [text "false"])
  ppp (IfP p p2 p3) = (pppSexp [text "if",(ppp p),(ppp p2),(ppp p3)])
  ppp (BeginP l p) = (pppSexp (text "begin" : ((map ppp l) ++ [(ppp p)])))
  ppp (AppP r t t2) = (pppSexp [(ppp r),(ppp t),(ppp t2)])
instance PP Effect where
  pp (Nop) = (ppSexp [fromByteString "nop"])
  pp (IfE p e e2) = (ppSexp [fromByteString "if",(pp p),(pp e),(pp e2)])
  pp (BeginE l e) = (ppSexp (fromByteString "begin" : ((map pp l) ++ [(pp e)])))
  pp (Mset t t2 t3) = (ppSexp [fromByteString "mset!",(pp t),(pp t2),(pp t3)])
  pp (ReturnPoint l t) = (ppSexp [fromByteString "return-point",(pp l),(pp t)])
  pp (Set1 v t) = (ppSexp [fromByteString "set!",(pp v),(pp t)])
  pp (Set2 v b t t2) = (ppSexp [fromByteString "set!",(pp v),(ppSexp [(pp b),(pp t),(pp t2)])])
  pp (Set3 v t t2) = (ppSexp [fromByteString "set!",(pp v),(ppSexp [fromByteString "mref",(pp t),(pp t2)])])
  ppp (Nop) = (pppSexp [text "nop"])
  ppp (IfE p e e2) = (pppSexp [text "if",(ppp p),(ppp e),(ppp e2)])
  ppp (BeginE l e) = (pppSexp (text "begin" : ((map ppp l) ++ [(ppp e)])))
  ppp (Mset t t2 t3) = (pppSexp [text "mset!",(ppp t),(ppp t2),(ppp t3)])
  ppp (ReturnPoint l t) = (pppSexp [text "return-point",(ppp l),(ppp t)])
  ppp (Set1 v t) = (pppSexp [text "set!",(ppp v),(ppp t)])
  ppp (Set2 v b t t2) = (pppSexp [text "set!",(ppp v),(pppSexp [(ppp b),(ppp t),(ppp t2)])])
  ppp (Set3 v t t2) = (pppSexp [text "set!",(ppp v),(pppSexp [text "mref",(ppp t),(ppp t2)])])
instance PP Triv where
  pp (Integer i) = (pp i)
  pp (Label l) = (pp l)
  pp (Var v) = (pp v)
  ppp (Integer i) = (ppp i)
  ppp (Label l) = (ppp l)
  ppp (Var v) = (ppp v)
instance PP Prog where
  pp (Letrec l b) = (ppSexp [fromByteString "letrec",(ppSexp (map (\(l,b) -> (ppSexp [(pp l),(ppSexp [fromByteString "lambda",(ppSexp []),(pp b)])])) l)),(pp b)])
  ppp (Letrec l b) = (pppSexp [text "letrec",(pppSexp (map (\(l,b) -> (pppSexp [(ppp l),(pppSexp [text "lambda",(pppSexp []),(ppp b)])])) l)),(ppp b)])
instance PP Loc where
  pp (Reg r) = (pp r)
  pp (FVarL f) = (pp f)
  ppp (Reg r) = (ppp r)
  ppp (FVarL f) = (ppp f)
instance PP Var where
  pp (UVarV u) = (pp u)
  pp (Loc l) = (pp l)
  ppp (UVarV u) = (ppp u)
  ppp (Loc l) = (ppp l)
instance PP Frame where
  pp (AppF l) = (ppSexp (map pp l))
  ppp (AppF l) = (pppSexp (map ppp l))
instance PP Body where
  pp (Locals l l2 l3 l4 l5 t) = (ppSexp [fromByteString "locals",(ppSexp (map pp l)),(ppSexp [fromByteString "new-frames",(ppSexp (map pp l2)),(ppSexp [fromByteString "spills",(ppSexp (map pp l3)),(ppSexp [fromByteString "frame-conflict",(ppSexp (map (\(u,l) -> (ppSexp ((pp u) : (map pp l)))) l4)),(ppSexp [fromByteString "call-live",(ppSexp (map pp l5)),(pp t)])])])])])
  ppp (Locals l l2 l3 l4 l5 t) = (pppSexp [text "locals",(pppSexp (map ppp l)),(pppSexp [text "new-frames",(pppSexp (map ppp l2)),(pppSexp [text "spills",(pppSexp (map ppp l3)),(pppSexp [text "frame-conflict",(pppSexp (map (\(u,l) -> (pppSexp ((ppp u) : (map ppp l)))) l4)),(pppSexp [text "call-live",(pppSexp (map ppp l5)),(ppp t)])])])])])
instance PP UFVar where
  pp (UVarU u) = (pp u)
  pp (FVarU f) = (pp f)
  ppp (UVarU u) = (ppp u)
  ppp (FVarU f) = (ppp f)

deriving instance Eq Tail
deriving instance Read Tail
deriving instance Show Tail
deriving instance Ord Tail
deriving instance Eq Pred
deriving instance Read Pred
deriving instance Show Pred
deriving instance Ord Pred
deriving instance Eq Effect
deriving instance Read Effect
deriving instance Show Effect
deriving instance Ord Effect
deriving instance Eq Triv
deriving instance Read Triv
deriving instance Show Triv
deriving instance Ord Triv
deriving instance Eq Prog
deriving instance Read Prog
deriving instance Show Prog
deriving instance Ord Prog
deriving instance Eq Loc
deriving instance Read Loc
deriving instance Show Loc
deriving instance Ord Loc
deriving instance Eq Var
deriving instance Read Var
deriving instance Show Var
deriving instance Ord Var
deriving instance Eq Frame
deriving instance Read Frame
deriving instance Show Frame
deriving instance Ord Frame
deriving instance Eq Body
deriving instance Read Body
deriving instance Show Body
deriving instance Ord Body
deriving instance Eq UFVar
deriving instance Read UFVar
deriving instance Show UFVar
deriving instance Ord UFVar

