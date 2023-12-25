module Main

import Network.Socket
import Network.Socket.Data

namespace Sqlite
  %foreign "C:sqlite3_libversion,libzero"
  sqlite3_libversion : PrimIO String

  public export
  sqliteVersion : IO ()
  sqliteVersion = do
    v <- primIO sqlite3_libversion
    printLn $ "Sqlite version " ++ v

  %foreign "C:create_sqlite_ref,libzero"
  createSqliteRef : (path: String) -> PrimIO (Ptr AnyPtr)

  %foreign "C:deref_sqlite,libzero"
  derefSqlite : (sqliteRef: Ptr AnyPtr) -> PrimIO AnyPtr

  public export
  mkSqlite : String -> IO AnyPtr
  mkSqlite path = do
    ref <- primIO $ createSqliteRef path
    db <- primIO $ derefSqlite ref
    io_pure db

  %foreign "C:free_sqlite,libzero"
  freeSqlite : (sqlite3: AnyPtr) -> PrimIO Unit

  public export
  unmkSqlite : AnyPtr -> IO ()
  unmkSqlite db = primIO $ freeSqlite db

  %foreign "C:exec_query_sqlite,libzero"
  execQuerySqlite : (sqlite3: AnyPtr) -> PrimIO String

  public export
  querySqlite : AnyPtr -> IO String
  querySqlite db = do
    result <- primIO $ execQuerySqlite db
    io_pure result

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
  Sqlite.sqliteVersion
  db <- Sqlite.mkSqlite "./db.sqlite3"
  users <- Sqlite.querySqlite db
  printLn users
  printLn "world"
  Sqlite.unmkSqlite db

  -- Web.mkServer 5000 "localhost"
