import Data.Char
import Data.Function
import Data.Map (Map)
import qualified Data.List as L
import qualified Data.Map as M


findLongest :: [String] -> [String]
findLongest = last
              . L.groupBy ((==) `on` length)
              . L.sortBy (compare `on` length)

createDictionary :: String -> Map Char Int
createDictionary cs = M.fromListWith (+) [(c, 1) | c <- filter isAlpha cs]

canBuild :: Map Char Int -> String -> Bool
canBuild _ []     = True
canBuild m (c:cs) = case M.lookup c m of
                      Nothing    -> False
                      Just 0     -> False
                      Just _     -> canBuild (M.adjust pred c m) cs

dp175 :: String -> String -> [String]
dp175 cs = findLongest . filter (canBuild d) . words
           where d = createDictionary cs

main :: IO ()
main = do
  ws <- getLine
  cs <- getLine
  case dp175 cs ws of [] -> print "No Anagrams Fount."
                      as -> do putStrLn "Found:"
                               mapM_ putStrLn as
