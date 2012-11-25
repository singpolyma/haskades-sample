module Types where

data Slots = Slots {
		mkFile :: String -> IO ()
	}

data Signal = ClockTick String
