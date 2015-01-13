import Data.List (delete, sortBy)
import Data.Ord (comparing)

contains :: String -> String -> Bool
contains _ [] = True
contains [] _ = False
contains chars (x:xs)
      | x `elem` chars = contains (delete x chars) xs
      | otherwise      = False

longestWords :: [String] -> String -> [String]
longestWords ws chars = takeWhile ((==maxL) . length) ws' where
      ws'   = sortBy (flip (comparing length)) $ filter (contains chars) ws
      maxL = length $ head ws'

main :: IO ()
main = do
      ws <- fmap words getLine
      chars <- fmap (filter (/=' ')) getLine
      let longest = longestWords ws chars
      if null longest then putStrLn "No Words Found"
      else mapM_ putStrLn longest