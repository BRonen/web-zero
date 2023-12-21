module Main

data Fin : Nat -> Type where
  FZ : Fin (S k)
  FS : Fin k -> Fin (S k)

Show (Equal x y) where
  show _ = "Equality"

Show (Fin k) where
  show (FS k) = "fS { " ++ show k ++ " }"
  show _ = "fZ"

public export
f' : Bool -> Type
f' True = (Nat, Nat)
f' False = Nat

public export
f : (t: Bool) -> Nat -> f' t
f True x = (x, x * 2)
f False x = x * 2

g : (t : Nat) -> Fin (S t)
g 0 = FZ
g (S x) = FS $ g $ x

mutual
  even : Nat -> Bool
  even Z = True
  even (S k) = odd k

  odd : Nat -> Bool
  odd Z = False
  odd (S k) = even k

addMaybe : (Maybe Nat) -> (Maybe Nat) -> (Maybe Nat)
addMaybe x y = Just $ !x + !y

twoPlusTwo : 2 + 2 = 4
twoPlusTwo = Refl

-- !
disjoint : (n : Nat) -> Equal Z (S n) -> Void
disjoint n prf = replace {p = disjointTy} prf ()
  where
    disjointTy : Nat -> Type
    disjointTy Z = ()
    disjointTy (S k) = Void

plusReduces : (n: Nat) -> 0 + n = n
plusReduces n = Refl

plusReducesZ : (n: Nat) -> n + 0 = n
plusReducesZ Z = Refl
plusReducesZ (S k) = plusReducesZ (S k)

main : IO ()
main = do
  putStrLn "hello world"
  printLn $ f False 2
  printLn $ g 0
  printLn $ g 1
  printLn $ g 2
  printLn $ g 3
  printLn $ g 4
  printLn $ odd 1
  printLn $ even 1
  printLn $ addMaybe (Just 2) (Just 3)
  printLn $ addMaybe (Just 2) (Nothing)
  printLn $ twoPlusTwo
  printLn $ plusReduces 2
