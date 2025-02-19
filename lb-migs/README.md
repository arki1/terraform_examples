# Global Load Balancer and Managed Instance Groups

## Cloning this repository into your Cloud Shell

Make sure you are using your own demo project. 

```sh
gcloud config set project YOUR_PROJECT_ID
```

Clone the repository by using this:

```sh
git clone https://github.com/arki1/terraform_examples.git
```

Go to this example folder by running:
```sh
cd terraform_examples/lb-migs
```

## Building Image to be Used in Cloud Run

In Cloud Shell, run:

```sh
cd container-app/
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/container-hello
```

## Define a subdomain prefix

Define a prefix in which the endpoing will use for the subdomain. `https://YOUR_PREFIX.arki1.cloud`
We recommend using your or any unique nickname to avoid colision with other instructors.

```sh
YOUR_PREFIX=<your_name_or_nickname>
```

## 🚀 Running Terraform in Cloud Shell

If your Terraform files are stored in Cloud Shell, simply:

```sh
cd ..
cd terraform/
terraform init
```

```sh
terraform apply -var="project_id=$DEVSHELL_PROJECT_ID" -var="subdomain=$YOUR_PREFIX"
```

And you're good to go! 🚀

## Testing

You can test it directly in the browser using the subdomain endpoint. (Note the output values in the end of the terraform execution). Note the [delays in SSL Certificate Provisioning and DNS propagation](#delays-in-ssl-certificate-provisioning-and-dns-propagation).

Or you can just run a curl:

```sh
curl https://$YOUR_PREFIX.arki1.cloud
```

So calling this URL from your local browser would show you one region, can calling it from Cloud Shell may already show you a DIFFERENT region, as cloud shell usually runs in US.

Note that the colors change BASED on the region in which the service is deployed.

As the Load Balancers are still not properly defined, when the region fails, please make SEVERAL attempts to make it switch to a different region. Remember, every minute, one of the regions will fail.


## Delays in SSL Certificate Provisioning and DNS propagation

Sadly, it takes a long time (~30min) for SSL certificates to be provisioned.

If you check certificate in the Load Balancer frontend, you can confirm its status. If it's provisioning, that means it's pending.

From the certificate's console (it's a property from the Load Balancer's frontend):

> Please wait 24h for certificate provisioning before contacting support. Learn more about managed certificates. 

Besides that, you'll also have to wait until the DNS configuration gets propagated.


## Dependency on Arki1 Cloud DNS

Please check the `arki1-cloud` project to see the configurations related to DNS.


## Cleaning up the environment

After using it, we recommend that you clean up the environment to release resources and avoid unnecessary costs.

Doing the way it's described below, you won't be destroying the SSL certificate, and will make it faster to provision it again - if necessary.

```sh
terraform destroy \
  -var="project_id=$DEVSHELL_PROJECT_ID" \
  -var="subdomain=$YOUR_PREFIX" \
  -target="google_compute_firewall.default" \
  -target="google_service_account.vm_service_account" \
  -target="google_project_iam_member.artifact_registry_access" \
  -target="google_project_iam_member.storage_access" \
  -target="google_compute_router.nat_router" \
  -target="google_compute_router_nat.cloud_nat" \
  -target="google_compute_instance_template.vm_template" \
  -target="google_compute_region_instance_group_manager.mig" \
  -target="google_compute_health_check.default" \
  -target="google_compute_backend_service.backend" \
  -target="google_compute_global_forwarding_rule.https_forwarding_rule" \
  -target="google_compute_target_https_proxy.https_proxy" \
  -target="google_compute_url_map.url_map" \
  -target="google_compute_region_network_endpoint_group.serverless_neg" \
  -target="google_dns_record_set.subdomain"
```

Note: MIGs are really hard to delete. They take SO LONG that sometimes terraform gives up waiting for them. You may have to retry destruction a few times.


## FAQ & Troubleshooting

### Error SSL Certificate already exists

> Error: Error creating ManagedSslCertificate: googleapi: Error 409: The resource 'projects/YOUR_PROJECT/global/sslCertificates/cloudrun-ssl-cert-YOUR_PREFIX' already exists

In this case, you already have a certificate and terraform is trying to create it. To fix it, you must import it to terraform state.

```sh
terraform import \
  -var="project_id=$DEVSHELL_PROJECT_ID" \
  -var="subdomain=$YOUR_PREFIX" \
  google_compute_managed_ssl_certificate.ssl_cert projects/$DEVSHELL_PROJECT_ID/global/sslCertificates/cloudrun-ssl-cert-$YOUR_PREFIX
```

### Useful commands

Useful commands when SSHing into the MIG's VM instances.

Check if the container is running:

```sh
docker ps
```

Check if the images were pulled:

```sh
docker images ls
```

See logs:

```sh
sudo journalctl -u konlet-startup --no-pager
sudo journalctl -u google-startup-scripts --no-pager
```

Not used, but in some cases this is used instead of docker. Just writing it down.

```sh
sudo crictl ps
```
