
module FarRP.SigVect

import FarRP.Time


%access public export
%default total


data Init : Type where
  Ini : Init
  Uni : Init

data SigDesc : Type where
  E : Type -> SigDesc
  C : Init -> Type -> SigDesc

SVDesc : Type
SVDesc = List SigDesc

data SVRep : SVDesc -> Type where
  SVRNil : SVRep []
  ECons : Maybe a -> SVRep as -> SVRep ((E a) :: as)
  CCons : a -> SVRep as -> SVRep ((C i a) :: as)
  UnInitCons : SVRep as -> SVRep ((C Uni a) :: as)

||| An empty event.
eEmpty : SVRep [E a]
eEmpty = ECons Nothing SVRNil

||| An event containing a value.
eSingle : a -> SVRep [E a]
eSingle x = ECons (Just x) SVRNil

cSingle : a -> SVRep [C i a]
cSingle x = CCons x SVRNil

eHead : SVRep (E a :: as) -> Maybe a
eHead (ECons x _) = x

cHead : SVRep (C i a :: as) -> Maybe a
cHead (CCons x _) = Just x
cHead (UnInitCons _) = Nothing

tail : SVRep (a :: as) -> SVRep as
tail (ECons _ xs) = xs
tail (CCons _ xs) = xs
tail (UnInitCons xs) = xs


(++) : SVRep as -> SVRep bs -> SVRep (as ++ bs)
(++) {as} {bs} svr1 svr2 = append' as bs svr1 svr2
  where
    append' : (as : SVDesc) -> (bs : SVDesc) -> SVRep as -> SVRep bs -> SVRep (as ++ bs)
    append' [] bs SVRNil svr2 = svr2
    append' as [] svr1 SVRNil = replace {P = SVRep} (sym $ appendNilRightNeutral as) svr1
    append' ((E a) :: as) bs (ECons x xs) svr2 = ECons x (append' as bs xs svr2)
    append' ((C Ini a) :: as) bs (CCons x xs) svr2 = CCons x (append' as bs xs svr2)
    append' ((C Uni a) :: as) bs (CCons x xs) svr2 = CCons x (append' as bs xs svr2)
    append' ((C Uni a) :: as) bs (UnInitCons xs) svr2 = UnInitCons (append' as bs xs svr2)


split : SVRep (as ++ bs) -> (SVRep as, SVRep bs)
split {as} {bs} svr = split' as bs svr
  where
    split' : (as : SVDesc) -> (bs : SVDesc) -> SVRep (as ++ bs) -> (SVRep as, SVRep bs)
    split' [] [] svr = (SVRNil, SVRNil)
    split' [] bs svr = (SVRNil, svr)
    split' as [] svr = (replace {P = SVRep} (appendNilRightNeutral as) svr, SVRNil)
    split' ((E a) :: as) bs (ECons x xs) = let r = split' as bs xs
                                           in (ECons x (fst r), snd r)
    split' ((C Ini a) :: as) bs (CCons x xs) = let r = split' as bs xs
                                               in (CCons x (fst r), snd r)
    split' ((C Uni a) :: as) bs (CCons x xs) = let r = split' as bs xs
                                               in (CCons x (fst r), snd r)
    split' ((C Uni a) :: as) bs (UnInitCons xs) = let r = split' as bs xs
                                                  in (UnInitCons (fst r), snd r)
