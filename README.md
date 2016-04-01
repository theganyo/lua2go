Accessing Go via Lua (LuaJit)
=============================

This module is designed as a way to allow access from Lua to Go. We use it for easy access to Go libraries from nginx using the LuaJit module.

To use (see also the [example](./example):

1. Write your Go module and `export` your functions:

    ```
    //export add
    func add(operand1 int, operand2 int) int {
        return operand1 + operand2
    }
    ```

2. Build your go module as a shared library:

    `go build -buildmode=c-shared -o example.so example.go`

3. Include a bit of setup in your Lua file:

    ```
    local lua2go = require('lua2go')
    local example = lua2go.Load('./example.so')
    ```

4. Register your `extern` declarations from your header file (`example.h`) in your Lua:

    ```
    lua2go.Externs[[
      extern GoInt add(GoInt p0, GoInt p1);
    ]]
    ```

5. Call your Go function from Lua (see [example](./example) for more detail):

    ```
    local result = lua2go.ToGo(example.add(1, 1))
    ```

6. Run your app:

    `luajit myapp.lua`

7. Bask in the glory of all that you've accomplished!


BTW: If you want to run some nginx benchmarks, go [here](./benchmark) and have at it!
