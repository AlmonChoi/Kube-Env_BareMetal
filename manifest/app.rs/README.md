# Kube-Env
Building Bare-Metal Kubernetes development environment with demo application using \[`expressCart`](https://github.com/mrvautin/expressCart)

### Implementation of MongoDB replica set using \[Mongodb Controllers for Kubernetes (MCK)](https://github.com/mongodb/mongodb-kubernetes) 

- Create MongoDB namespace

```
kubectl create namespace mongodb

```

- Install MCK using helm chart

```
helm repo add mongodb https://mongodb.github.io/helm-charts

kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes/1.5.0/public/crds.yaml

helm upgrade --install mongodb-kubernetes-operator mongodb/mongodb-kubernetes --namespace mongodb 

```

- Verify Mongo CE CRDs installed:

```
kubectl get crds | grep mongodb

mongodbcommunity.mongodbcommunity.mongodb.com   2025-10-29T22:35:33Z

```

- Verify MCK operator started:

```
kubectl get pods -n mongodb
```

NAME                                           READY   STATUS    RESTARTS   AGE
mongodb-kubernetes-operator-7898cfb5f8-k8r6k   1/1     Running   0          62s







