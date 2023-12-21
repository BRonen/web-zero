module Tests

import Main

main : IO ()
main = do
    printLn $ f True 2
    putStrLn "tests passed"
