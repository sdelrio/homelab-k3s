# Percona test

## query measure

- [https://www.digitalocean.com/community/tutorials/how-to-measure-mysql-query-performance-with-mysqlslap]

```
kubectl apply -f demo-percona-mysql-pvc.yaml
mysqlslap --user=root --password=k8sDem0 --host=localhost  --auto-generate-sql --concurrency=50 --iterations=100 --number-int-cols=5 --number-char-cols=20 --verbose
```

