# ez-ipupdate-docker
Docker container to update dynamic DNS host entries using ez-ipupdate.

To use, rename `ez-update.example.conf` to `ez-ipupdate.conf` and edit the file (see [here](https://linux.die.net/man/8/ez-ipupdate) for help). To run, use:

```
docker built -t ez-ipupdate .
docker run -v $PWD/ez-ipupdate.conf:/etc/ez-ipupdate.conf ez-ipupdate
```

The container will run indefinitely, checking your IP for updates every half an hour. Supports any dynamic DNS service that uses the dyndns protocol. 
