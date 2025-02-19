# Global Load Balancer and Cloud Run

This example demonstrates how to deploy a **sample application** across multiple **Cloud Run services**, attach them to a **Global Load Balancer**, and manage failover using **Network Endpoint Groups (NEGs)**.

## **Overview**
- The application is deployed in **six different regions**.
- A **single backend** is created, pointing to **multiple NEGs** (each representing a Cloud Run service in a different region).
- The **Load Balancer routes traffic to the nearest region** for the caller.
- **Failure Handling:** Each region is intentionally configured to fail for **one minute** to test failover behavior.

## **Expected Behavior**
1. **Traffic is routed to the nearest healthy region.**
2. If the **Cloud Run service fails**, the **Load Balancer should automatically shift traffic** to another healthy region.

## **Improvements & Future Work**
- The **`outlier_detection` attribute** could be fine-tuned to enhance failure detection and recovery.
- Currently, the failover **partially works but is not perfect**.

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
```

## Define a subdomain prefix

Define a prefix in which the endpoing will use for the subdomain. `https://YOUR_PREFIX.arki1.cloud`
We recommend using your or any unique nickname to avoid colision with other instructors.

```sh
YOUR_PREFIX=<your_name_or_nickname>
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
cd terraform/
terraform destroy \
  -var="project_id=$DEVSHELL_PROJECT_ID" \
  -var="subdomain=$YOUR_PREFIX" \
  -target="google_cloud_run_service.cloudrun_service" \
  -target="google_compute_backend_service.backend" \
  -target="google_compute_global_forwarding_rule.https_forwarding_rule" \
  -target="google_compute_target_https_proxy.https_proxy" \
  -target="google_compute_url_map.url_map" \
  -target="google_compute_region_network_endpoint_group.serverless_neg" \
  -target="google_dns_record_set.subdomain"
```

## FAQ - Errors

### Error SSL Certificate already exists

> Error: Error creating ManagedSslCertificate: googleapi: Error 409: The resource 'projects/YOUR_PROJECT/global/sslCertificates/cloudrun-ssl-cert-YOUR_PREFIX' already exists

In this case, you already have a certificate and terraform is trying to create it. To fix it, you must import it to terraform state.
```sh
terraform import \
  -var="project_id=$DEVSHELL_PROJECT_ID" \
  -var="subdomain=$YOUR_PREFIX" \
  google_compute_managed_ssl_certificate.ssl_cert projects/$DEVSHELL_PROJECT_ID/global/sslCertificates/cloudrun-ssl-cert-$YOUR_PREFIX
```