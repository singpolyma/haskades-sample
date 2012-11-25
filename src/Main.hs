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

main :: IO ()
main = do
	void $ forkIO clockThread
	haskadesRun "asset:///ui.qml" Slots {
		mkFile = (`writeFile` "lol file\n")
	}
