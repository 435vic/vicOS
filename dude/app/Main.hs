module Main where

import Options.Applicative
import CLIOptions
import Sync

main :: IO ()
main = execParser rootParser >>= handler

handler :: RootCommand -> IO ()
handler (Sync opts) = sync opts 
  
