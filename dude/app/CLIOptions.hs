module CLIOptions where

import Options.Applicative

data RootCommand = Sync SyncOptions
  deriving (Show)

data SyncOptions = SyncOptions {edit :: Bool, force :: Bool} deriving (Show)

syncParser :: ParserInfo SyncOptions
syncParser =
  info
    (options' <**> helper)
    ( fullDesc
        <> progDesc "apply configuration to current system"
        <> header "dude sync - nixos-rebuild but better"
    )
  where
    options' =
      SyncOptions
        <$> switch
          ( long "edit"
              <> short 'e'
              <> help "Edit using $EDITOR before syncing"
          )
        <*> switch
          ( long "force"
              <> short 'f'
              <> help "sync even if working tree is dirty"
          )

rootParser :: ParserInfo RootCommand
rootParser =
  info
    (rootParser' <**> helper)
    ( fullDesc
        <> progDesc "manager for vicOS"
    )
  where
    rootParser' =
      Sync
        <$> subparser
          ( command "sync" syncParser
          )
