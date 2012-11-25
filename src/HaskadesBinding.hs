module HaskadesBinding (haskadesRun, emit) where

import Foreign.C.Types
import Foreign.C.String
import Foreign.Ptr
import System.Exit (exitWith,  ExitCode(ExitFailure))
import Control.Monad (when)
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text
import qualified Data.ByteString as ByteString

import Types

foreign import ccall safe "haskades_run.cpp haskades_run"
	c_haskades_run ::
	CString -> FunPtr (CString -> IO ()) ->
	IO CInt

foreign import ccall unsafe "start.cpp emit_CustomSignalEvent"
	c_emit_CustomSignalEvent ::
	CInt -> CString ->
	IO ()

emit :: Signal -> IO ()
emit (ClockTick str0) = ByteString.useAsCString (Text.encodeUtf8 $ Text.pack str0) (\str0 -> c_emit_CustomSignalEvent 1 str0)

-- Function pointer wrappers
foreign import ccall "wrapper" wrap_mkFile :: (CString -> IO ()) -> IO (FunPtr (CString -> IO ()))

haskadesRun :: String -> Slots -> IO ()
haskadesRun qmlPath (Slots mkFile) = do
	mkFilePtr <- wrap_mkFile (\arg0 -> fmap (Text.unpack . Text.decodeUtf8) (ByteString.packCString arg0) >>= mkFile)

	code <- ByteString.useAsCString (Text.encodeUtf8 $ Text.pack qmlPath) (\qmlPath -> c_haskades_run qmlPath mkFilePtr)

	freeHaskellFunPtr mkFilePtr

	when (code /= 0) (exitWith $ ExitFailure $ fromIntegral code)
	return ()
