module Main

import Network.Socket
import Network.Socket.Data

namespace Sqlite
  data SqlitePtr = AnyPtr

  %foreign "C:allocVoidPtr,c_utils.h"
  allocVoidPtr : () -> PrimIO (Ptr SqlitePtr)

  %foreign "C:free,libc"
  free : SqlitePtr -> PrimIO ()

  %foreign "C:sqlite3_open, sqlite3"
  sqlite3_open : (filename: String) -> (sqlite3: Ptr SqlitePtr) -> Int

  %foreign "C:sqlite3_close, sqlite3"
  sqlite3_close : (sqlite3: SqlitePtr) -> Int

  %foreign "C:sqlite3_exec, sqlite3"
  sqlite3_exec : (sqlite3: SqlitePtr) -> (sql: String) -> (callback: AnyPtr) -> (param: AnyPtr) -> (errmsg: Ptr String) -> Int
  
  mkSqlite : String -> IO SqlitePtr
  mkSqlite path = do
    sqlite <- primIO $ allocVoidPtr ()
    sqlite3_open "./db.sqlite3" sqlite
    ?wasd

namespace Web
  handleRequest : Either SocketError (Socket, SocketAddress) -> IO ()
  handleRequest (Left sockErr) = printLn "hello world2"
  handleRequest (Right (sock, sockAddr)) = do
    let status = "500"
    let status_text = "Ok"
    _ <- send sock $ "HTTP/1.1 " ++ status ++ " " ++ status_text ++ "\r\nContent-Type: application/json\r\nContent-Length: 12\r\n\r\nhello world!\r\n"
    printLn sockAddr

  acceptLoop : Socket -> IO()
  acceptLoop sock = do
    handleRequest =<< accept sock
    acceptLoop sock

  public export
  mkServer : Int -> (host: String) -> IO ()
  mkServer port host = do
    tcpSock <- socket AF_INET Stream 0

    case tcpSock of
      Left sockErr => printLn $ show sockErr
      Right sock => do
        socketBound <- bind sock (Just $ Hostname host) port
        printLn $ show socketBound

        socketBound' <- listen sock
        printLn $ show socketBound'
        
        acceptLoop sock

main : IO ()
main = Web.mkServer 5000 "localhost"
