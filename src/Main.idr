module Main

import Network.Socket
import Network.Socket.Data
import System.FFI

namespace Sqlite
  public export
  QueryResult : Type
  QueryResult = Struct "state_node" [("value", Ptr AnyPtr), ("next", Ptr QueryResult)]

  sqlite3_lib : String -> String
  sqlite3_lib fn = "C:" ++ fn ++ ",libzero"

  public export
  %foreign (sqlite3_lib "sqlite3_libversion")
  sqlite3_libversion : PrimIO String

  public export
  %foreign (sqlite3_lib "dump_query_state")
  dumpQueryState : Ptr QueryResult -> PrimIO Unit

  public export
  sqliteVersion : IO ()
  sqliteVersion = do
    v <- primIO sqlite3_libversion
    printLn $ "Sqlite version " ++ v

  %foreign (sqlite3_lib "create_sqlite_ref")
  createSqliteRef : (path: String) -> PrimIO (Ptr AnyPtr)

  %foreign (sqlite3_lib "deref_sqlite")
  derefSqlite : (sqliteRef: Ptr AnyPtr) -> PrimIO AnyPtr

  public export
  %foreign (sqlite3_lib "deref")
  derefQueryResult : Ptr QueryResult -> PrimIO QueryResult

  public export
  mkSqlite : String -> IO AnyPtr
  mkSqlite path = do
    ref <- primIO $ createSqliteRef path
    db <- primIO $ derefSqlite ref
    io_pure db

  %foreign (sqlite3_lib "free_sqlite")
  freeSqlite : (sqlite3: AnyPtr) -> PrimIO Unit

  public export
  unmkSqlite : (sqlite3: AnyPtr) -> IO ()
  unmkSqlite db = primIO $ freeSqlite db

  %foreign (sqlite3_lib "exec_query_sqlite")
  execQuerySqlite : (sqlite3: AnyPtr) -> String -> Ptr QueryResult

  public export
  querySqlite : (sqlite3: AnyPtr) -> String -> IO QueryResult
  querySqlite db query = do
    let resultRef = execQuerySqlite db query
    result <- primIO $ derefQueryResult resultRef
    io_pure result

  public export
  %foreign (sqlite3_lib "get_column_string")
  getColumn : Int -> QueryResult -> PrimIO String

  public export
  %foreign (sqlite3_lib "get_next_row")
  getNextRow : QueryResult -> PrimIO (Ptr QueryResult)

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
  user <- Sqlite.querySqlite db "SELECT * FROM users;"
  query_data <- primIO $ Sqlite.getColumn 1 user
  printLn "wasdwad"
  userRef <- primIO $ Sqlite.getNextRow user
  printLn "wasdwad"
  primIO $ Sqlite.dumpQueryState userRef
  printLn "wasdwad"
  -- user <- primIO $ Sqlite.derefQueryResult userRef
  -- query_data <- primIO $ Sqlite.getColumn 1 user
  -- printLn query_data
  Sqlite.unmkSqlite db

  -- Web.mkServer 5000 "localhost"
