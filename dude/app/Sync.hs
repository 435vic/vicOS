module Sync where

import CLIOptions (SyncOptions)

sync :: SyncOptions -> IO ()
sync opts = print opts

