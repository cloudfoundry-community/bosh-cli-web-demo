# README

Using traditional `cf push`:

```
export BOSH_ENVIRONMENT=<alias>

cf push --no-start

cf set-env bosh-ui-demo BOSH_ENVIRONMENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/url)
cf set-env bosh-ui-demo BOSH_CLIENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/username)
cf set-env bosh-ui-demo BOSH_CLIENT_SECRET "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/password)"
cf set-env bosh-ui-demo BOSH_CA_CERT "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/ca_cert)"

cf push
```

Using new `cf v3-push` commands:

```
export BOSH_ENVIRONMENT=<alias>

cf v3-push --no-start

cf v3-set-env bosh-ui-demo BOSH_ENVIRONMENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/url)
cf v3-set-env bosh-ui-demo BOSH_CLIENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/username)
cf v3-set-env bosh-ui-demo BOSH_CLIENT_SECRET "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/password)"
cf v3-set-env bosh-ui-demo BOSH_CA_CERT "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/ca_cert)"

cf v3-push
```

You will probably need to open a new Cloud Foundry Security Group to allow this application to access your BOSH director. The following will create a new security group that only allows access to your BOSH director over ports 25555 and 22 (for ssh tunnels).

```
cf create-security-group boshenv-$BOSH_ENVIRONMENT <(./bin/bosh-security-group)
current_org_name=$(bosh int ~/.cf/config.json --path /OrganizationFields/Name)
current_space_name=$(bosh int ~/.cf/config.json --path /SpaceFields/Name)
cf bind-security-group boshenv-$BOSH_ENVIRONMENT $current_org_name $current_space_name
```
