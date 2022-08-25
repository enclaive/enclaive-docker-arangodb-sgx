# Running

```bash
php generate_data.php > data.json
docker-compose up -d
```

# Demonstrating

Use two shells in demo:

```bash
docker-compose exec demo bash
docker-compose exec demo bash
```

```bash
# first
fswatch -artux /sgx/data/
fswatch -artux /vanilla/data/

# second
arangosh --server.authentication false --server.endpoint tcp://sgx:8529
> db._create("testDb");

arangosh --server.authentication false --server.endpoint tcp://vanilla:8529
> db._create("testDb");
```

The file should be located somewhere at `/sgx/data/engine-rocksdb/journals/000115.log`. Same goes for `/vanilla/data/engine-rocksdb/journals/000114.log`.

We can now watch the file as we import our data:

```bash
# first
tail -q -c 0 -f /sgx/data/engine-rocksdb/journals/*.log     | strings
tail -q -c 0 -f /vanilla/data/engine-rocksdb/journals/*.log | strings

# second
arangoimport --server.authentication false --server.endpoint tcp://sgx:8529     --collection users --create-collection true --file data.json
arangoimport --server.authentication false --server.endpoint tcp://vanilla:8529 --collection users --create-collection true --file data.json
```

Instead of `strings` we also could use `xxd -c 64`, but it is sometimes harder to find our imported data due to other things also written to this log.

Or simply do a `grep`:

```bash
grep -Ri testUsername /vanilla/ /sgx/
```
