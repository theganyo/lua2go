Benchmarking Go via LuaJit in nginx
===================================

1. build the benchmark library

    ```
    cd go
    go build -buildmode=c-shared -o benchmark.so benchmark.go
    cd ..
    ```

2. install openresty (or nginx w/ LuaJit library)

3. add localhost aliases: 'local', 'proxy', and 'target' to your /etc/hosts

4. execute: `openresty -p $PWD -c conf/nginx.conf`

5. start node proxy (optional)

    ```
    cd node
    npm install
    node app.js
    ```

6. You will now have the following endpoints to hit for various benchmarks:

    `http://localhost:3000/echo` : nginx echo

    `http://localhost:3000/file` : nginx serve small static file

    `http://localhost:3000/lua2go` : nginx -> lua2go -> benchmark.go, echo result

    In addition, the following endpoints will proxy nginx -> nginx:

    `http://localhost:3001/echo` : nginx proxy_pass -> target nginx echo

    `http://localhost:3001/file` : nginx proxy_pass -> target nginx serve small static file

    `http://localhost:3001/lua2go` : nginx -> lua2go -> benchmark.go -> rewrite -> /echo

    And, if you ran the node proxy, the following endpoints will proxy node -> nginx:

    `http://localhost:3003/echo` : node -> nginx echo

    `http://localhost:3003/file` : nginx serve small static file

7. Run your own benchmarks! I don't have a script. :)

    You can install weighttp and try something like this:

    `weighttp -n 1000 -c 128 -t 128 -k -H "User-Agent: Me" localhost:3000/lua2go`
