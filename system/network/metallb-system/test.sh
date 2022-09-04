
cat << EOF | kubectl apply -n metallb-system -f -
apiVersion: v1
kind: Service
metadata:
  name: metallb-test
  annotations:
    metallb.universe.tf/address-pool: my-ip-space
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: test
  type: LoadBalancer
EOF

kubectl -n metallb-system get svc metallb-test
sleep 5
kubectl -n metallb-system get svc metallb-test
kubectl -n metallb-system delete service metallb-test

