module Main (main) where

import Foreign.C.Types
import Foreign.C.String
import Foreign.Ptr
import System.Exit (exitWith,  ExitCode(ExitFailure))

import Control.Concurrent
import Control.Monad (when, void, forever)
import Data.Time.Clock
import Data.Time.Format
import Data.Time.LocalTime
import System.Locale
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text
import qualified Data.ByteString as ByteString


data Slots = Slots {
		mkFile :: String -> IO ()
	}

foreign import ccall safe "haskades_run.cpp haskades_run"
	c_haskades_run ::
	CString -> FunPtr (CString -> IO ()) ->
	IO CInt

foreign import ccall safe "start.cpp emit_clockTick"
	c_emit_clockTick ::
	CString ->
	IO ()

emit_clockTick :: Text.Text -> IO ()
emit_clockTick str0 = textAsUtf8CString str0 c_emit_clockTick

foreign import ccall "wrapper" wrap_mkFile :: (CString -> IO ()) -> IO (FunPtr (CString -> IO ()))

haskadesRun :: Text.Text -> Slots -> IO ()
haskadesRun qmlPath (Slots mkFile) = do
	mkFilePtr <- wrap_mkFile (\arg0 -> fmap (Text.unpack . Text.decodeUtf8) (ByteString.packCString arg0) >>= mkFile)

	code <- textAsUtf8CString qmlPath (\qmlPath -> c_haskades_run qmlPath mkFilePtr)

	freeHaskellFunPtr mkFilePtr

	when (code /= 0) (exitWith $ ExitFailure $ fromIntegral code)
	return ()

textAsUtf8CString :: Text.Text -> (CString -> IO a) -> IO a
textAsUtf8CString = ByteString.useAsCString . Text.encodeUtf8

clockThread :: IO ()
clockThread = forever $ do
	time <- utcToLocalZonedTime =<< getCurrentTime
	emit_clockTick (Text.pack $ formatTime defaultTimeLocale "%H:%M:%S" time)
	threadDelay 1000000

main :: IO ()
main = do
	void $ forkIO clockThread
	haskadesRun (Text.pack "asset:///ui.qml") (Slots {
		mkFile = (\pth -> writeFile pth "lol file\n")
	})
