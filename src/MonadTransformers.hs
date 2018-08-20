module MonadTransformers
  ( Computation
  , run
  , ioProgram
  , program
  ) where

{-
 - This example solves the challenge in the most standard way: with a monad
 - transformer stack.
 -}
import Control.Monad (replicateM_)
import Control.Monad.Random (Rand, StdGen, getRandomR, mkStdGen, runRand)
import Control.Monad.State (StateT, get, put, runStateT)
import Control.Monad.Writer (WriterT, runWriterT, tell)

-- The monad
type Computation = WriterT String (StateT Integer (Rand StdGen))

-- The operations
getRandom :: Computation Integer
getRandom = getRandomR (0, 9)

getAccumulator :: Computation Integer
getAccumulator = get

setAccumulator :: Integer -> Computation ()
setAccumulator = put

logOutput :: String -> Computation ()
logOutput = tell

-- The program
program :: Computation ()
program =
  replicateM_ 10 $ do
    i <- getAccumulator
    logOutput (show i ++ "\n")
    r <- getRandom
    setAccumulator (r + i)
    return ()

-- An interpreter
run :: Computation a -> IO a
run c =
  let (((x, s), _), _) = runRand (runStateT (runWriterT c) 0) (mkStdGen 0)
  in putStrLn s >> return x

-- An interpretation of the program
ioProgram :: IO ()
ioProgram = run program
