module Main (main) where

import Control.Concurrent
import Control.Monad (void, forever)
import Data.Time.Clock
import Data.Time.Format
import Data.Time.LocalTime
import System.Locale

import Types
import HaskadesBinding

clockThread :: IO ()
clockThread = forever $ do
	time <- utcToLocalZonedTime =<< getCurrentTime
	emit $ ClockTick (formatTime defaultTimeLocale "%H:%M:%S" time)
	threadDelay 1000000

fromUIThread :: IO ()
fromUIThread = forever (popSignalFromUI >>= handleFromUI)

handleFromUI :: SignalFromUI -> IO ()
handleFromUI (MkFile pth) =  pth `writeFile` "lol file\n"

main :: IO ()
main = do
	void $ forkIO clockThread
	void $ forkIO fromUIThread
	haskadesRun "asset:///ui.qml"
