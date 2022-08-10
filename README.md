# enclaive-docker-arangodb-sgx

## Running

As `arangod` is currently built from source we do not recommend building on your own. This might change in the future, if gramine adds support for things listed under `Notes`.

```bash
docker-compose up
```

## Connecting

Use `arangosh` to connect to `hostname:8529` or use the web interface on the same address. No authentication is required for the shell as this a demo setup, a user account has to be created before logging in to the web interface.

## Notes

- The application currently breaks on restart due to issues with gramine
  - It is also unstable due to memory issues with javascript and fixed sizes for stack and memory
- A useless fork is removed from sources
- Unimplemented syscalls `splice` and `utimensat` are disabled during compilation
