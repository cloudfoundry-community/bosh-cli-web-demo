# BOSH CLI in a web app

This repo is a demonstration of:

* using Cloud Foundry [multi-buildpack](https://github.com/cloudfoundry/multi-buildpack/) to install external dependencies without forking normal buildpacks
* using Cloud Foundry [apt-buildpack](https://github.com/cloudfoundry/apt-buildpack/) to install Debian packages from custom repositories (`apt-get install bosh-cli` comes from https://apt.starkandwayne.com)
* building web apps that talk to a BOSH environment using the `bosh` CLI

An example from staging this app will show a custom Debian repository being used:

```
Staging package for app bosh-cli-web-demo in org system / space dev as admin...
   -----> Running go build supply
   -----> Apt Buildpack version 0.0.2
   -----> Updating apt cache
   Installing custom repository key from https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key
   gpg: key 535EAEC4: public key "Stark & Wayne Bot (Created by CI) <drnic+bot@starkandwayne.com>" imported
   gpg: Total number processed: 1
   gpg:               imported: 1  (RSA: 1)
   -----> Downloading apt packages
   -----> Installing apt packages
```

This example screenshot shows the `bosh` CLI being used directly. Configuration for the CLI is done via environment variables.

![demo](https://github.com/cloudfoundry-community/bosh-cli-web-demo/raw/master/public/bosh-ui-demo.png)

The template for this page directly runs `bosh` CLI commands; see [app/views/help/version.html.erb](https://github.com/cloudfoundry-community/bosh-cli-web-demo/blob/master/app/views/help/version.html.erb):

```html
<pre>
$ bosh -v
<%= `bosh -v || echo "ERROR: bosh CLI missing, install it using multi-buildpack/apt-buildpack"` %>

$ bosh env --tty
<%= `bosh env --tty` %>

$ bosh deployments
<%= `bosh deployments` %>
</pre>
```

The `bosh` CLI can be completely configured to target and authenticate against a BOSH environment via environment variables. See the deployment instructions for how to set these for a Cloud Foundry application.

## Deploy to Cloud Foundry

You can deploy this demo, or in general use multi-buildpack, on any Cloud Foundry. If you have a newer Cloud Foundry then you can try the `cf v3-push` method which brings multi-buildpack as a first-class citizen of the `cf` CLI.

### Open Security Group

You will probably need to open a new Cloud Foundry Security Group to allow this application to access your BOSH director. The following will create a new security group that only allows access to your BOSH director over ports 25555 and 22 (for ssh tunnels).

```
cf create-security-group boshenv-$BOSH_ENVIRONMENT <(./bin/bosh-security-group)
current_org_name=$(bosh int ~/.cf/config.json --path /OrganizationFields/Name)
current_space_name=$(bosh int ~/.cf/config.json --path /SpaceFields/Name)
cf bind-security-group boshenv-$BOSH_ENVIRONMENT $current_org_name $current_space_name
```

### Deploy using traditional cf push

```
export BOSH_ENVIRONMENT=<alias>

cf push --no-start

cf set-env bosh-cli-web-demo BOSH_ENVIRONMENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/url)
cf set-env bosh-cli-web-demo BOSH_CLIENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/username)
cf set-env bosh-cli-web-demo BOSH_CLIENT_SECRET "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/password)"
cf set-env bosh-cli-web-demo BOSH_CA_CERT "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/ca_cert)"

cf restart
```

### Deploy using cf v3-push

NOTE: at the time of writing I wasn't having success with v3 apps and security groups. This means that whilst `bosh` CLI is installed, it probably cannot connect outside of Cloud Foundry to your BOSH environment. Hopefully this issue is resolved in future and this section will work as expected.

Using new `cf v3-push` commands we can provide multiple `-b buildpack` flags. The final buildpack must be the runtime language buildpack. This application is a Ruby application, so `-b ruby_buildpack` is the last buildpack.

```
export BOSH_ENVIRONMENT=<alias>

cf v3-push bosh-cli-web-demo \
  -b https://github.com/drnic/apt-buildpack#custom-repositories \
  -b ruby_buildpack

cf v3-set-env bosh-cli-web-demo BOSH_ENVIRONMENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/url)
cf v3-set-env bosh-cli-web-demo BOSH_CLIENT $(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/username)
cf v3-set-env bosh-cli-web-demo BOSH_CLIENT_SECRET "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/password)"
cf v3-set-env bosh-cli-web-demo BOSH_CA_CERT "$(bosh int ~/.bosh/config --path /environments/alias=$BOSH_ENVIRONMENT/ca_cert)"

cf v3-restart bosh-cli-web-demo
```
