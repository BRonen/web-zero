module Main

import Network.Socket
import Network.Socket.Data

namespace Sqlite
  %foreign "C:allocVoidPtr,zero"
  allocVoidPtr : () -> PrimIO (Ptr AnyPtr)

  %foreign "C:allocVoidPtr,zero"
  allocStringPtr : () -> PrimIO (Ptr String)

  %foreign "C:deref,zero"
  deref : Ptr AnyPtr -> PrimIO AnyPtr

  %foreign "C:free,libc,stdlib.h"
  free : AnyPtr -> PrimIO ()

  %foreign "C:sqlite3_open,sqlite3,sqlite3.h"
  sqlite3_open : (filename: String) -> (sqlite3: Ptr AnyPtr) -> PrimIO Int

  %foreign "C:sqlite3_close,sqlite3,sqlite3.h"
  sqlite3_close : (sqlite3: AnyPtr) -> PrimIO Int

  %foreign "C:sqlite3_exec,sqlite3,sqlite3.h"
  sqlite3_exec : (sqlite3: AnyPtr) -> (sql: String) -> (callback: AnyPtr) -> (param: AnyPtr) -> (errmsg: Ptr String) -> PrimIO Int
  
  %foreign "C:callback,zero"
  callback : AnyPtr

  public export
  mkSqlite : String -> IO AnyPtr
  mkSqlite path = do
    s <- primIO $ allocVoidPtr ()
    _ <- primIO $ sqlite3_open path s
    primIO $ deref s

  public export
  unmkSqlite : AnyPtr -> IO ()
  unmkSqlite sqlite = do
    _ <- primIO $ sqlite3_close sqlite
    primIO $ free sqlite

  public export
  runQuery : AnyPtr -> String -> IO String
  runQuery sqlite query = do
  stringPtr <- primIO $ allocStringPtr ()
  rc <- primIO $ sqlite3_exec sqlite query callback callback stringPtr
  io_pure $ show rc

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
main = do
  db <- Sqlite.mkSqlite "./db.sqlite3"
  Sqlite.unmkSqlite db
  -- Web.mkServer 5000 "localhost"
