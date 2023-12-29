module Main

import Network.Socket
import Network.Socket.Data
import System.FFI

namespace Sqlite
  sqlite3_lib : String -> String
  sqlite3_lib fn = "C:" ++ fn ++ ",libzero"

  public export
  SqlitePtr : Type
  SqlitePtr = AnyPtr

  public export
  QueryResult : Type
  QueryResult = Struct "state_node" [("value", Ptr AnyPtr), ("next", Ptr QueryResult)]

  %foreign (sqlite3_lib "sqlite3_libversion")
  sqlite3_libversion : PrimIO String

  public export
  sqliteVersion : IO ()
  sqliteVersion = do
    v <- primIO sqlite3_libversion
    printLn $ "Sqlite version " ++ v

  %foreign (sqlite3_lib "create_sqlite_ref")
  createSqliteRef : (path: String) -> PrimIO (Ptr SqlitePtr)

  %foreign (sqlite3_lib "deref_sqlite")
  derefSqlite : (sqliteRef: Ptr SqlitePtr) -> PrimIO SqlitePtr

  public export
  mkSqlite : String -> IO SqlitePtr
  mkSqlite path = do
    ref <- primIO $ createSqliteRef path
    db <- primIO $ derefSqlite ref
    io_pure db

  %foreign (sqlite3_lib "free_sqlite")
  freeSqlite : (sqlite3: SqlitePtr) -> PrimIO Unit

  public export
  unmkSqlite : (sqlite3: SqlitePtr) -> IO ()
  unmkSqlite db = primIO $ freeSqlite db

  %foreign (sqlite3_lib "exec_query_sqlite")
  execQuerySqlite : (sqlite3: SqlitePtr) -> String -> QueryResult

  public export
  querySqlite : (sqlite3: SqlitePtr) -> String -> IO QueryResult
  querySqlite db query = do
    let result = execQuerySqlite db query
    io_pure result

  public export
  %foreign (sqlite3_lib "get_string")
  getString : Ptr AnyPtr -> PrimIO String

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
  users <- Sqlite.querySqlite db "SELECT * FROM users WHERE id = 5;"
  query_data <- primIO $ Sqlite.getString $ getField users "value"
  printLn query_data
  Sqlite.unmkSqlite db

  -- Web.mkServer 5000 "localhost"
