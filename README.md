# README

```
export BOSH_ENVIRONMENT=<alias>

cf push --no-start

cf set-env bosh-ui-demo BOSH_ENVIRONMENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/url)
cf set-env bosh-ui-demo BOSH_CLIENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/username)
cf set-env bosh-ui-demo BOSH_CLIENT_SECRET "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/password)"
cf set-env bosh-ui-demo BOSH_CA_CERT "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/ca_cert)"

cf push
```
