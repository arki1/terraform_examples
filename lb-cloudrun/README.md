# Load Balancer and Cloud Run

In this example, a sample application that shows each region it is deployed into is deployed in multiple cloud run services and attached to a Global Load Balancer. A backend is created pointing to multiple NEGs, each representing a Cloud Run Service in a region.

The application is deployed in 6 different regions and - on purpose - fails in one of these regions for a whole minute.

The nearest region to the load balancer caller should be chosen, but when it fails the load balancer should transfer traffic to the other regions.

NOTE: There are still improvements to be made in the `outlier_detection` attribute, to improve detection and recovering. Currently, it kinda works, but it's not perfect.

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
cd terraform_examples/lb-cloudrun
```

## Building Image to be Used in Cloud Run

In Cloud Shell, run:

```sh
cd cloudrun-app/
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/cloudrun-hello
```

## 🚀 Running Terraform in Cloud Shell

If your Terraform files are stored in Cloud Shell, simply:

```sh
cd ..
cd terraform/
terraform init
terraform apply -var="project_id=$DEVSHELL_PROJECT_ID"
```

You can either supply another field in the apply command specifying your desired subdomain, or you can just enter it manually when terraform asks for it.

```sh
terraform apply -var="project_id=$DEVSHELL_PROJECT_ID" -var="subdomain=YOUR_PREFIX"
```

If you supply `feu`, the endpoint will be `https://feu.arki1.cloud`. We recommend using your or any unique nickname to avoid colision with other instructors.

And you're good to go! 🚀


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
cd terraform/
terraform destroy \
  -var="project_id=$DEVSHELL_PROJECT_ID" \
  -var="subdomain=YOUR_PREFIX" \
  -target="google_cloud_run_service.cloudrun_service" \
  -target="google_compute_backend_service.backend" \
  -target="google_compute_global_forwarding_rule.https_forwarding_rule" \
  -target="google_compute_target_https_proxy.https_proxy" \
  -target="google_compute_url_map.url_map" \
  -target="google_compute_region_network_endpoint_group.serverless_neg" \
  -target="google_dns_record_set.subdomain"
```
