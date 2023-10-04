# AWS Service Catalog

Service Catalog centralized deployment of products:

<img src=".assets/servcat.png" />

Start by creating the Key Pair. This will be used during the product launch.

```sh
mkdir keys
ssh-keygen -f keys/tmp_key
```

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

Enter the console with the end user credentials and you should be able to deploy a product using Service Catalog.

<img src=".assets/products.png" />

When launching the product, inform the Key Pair and the CIDR block allowed to connect over SSH.

### Organization Sharing

Service Catalog has the distinct feature of being able to share products across Accounts, Organizations, and Organization Units.

This is possible by enabling a delegated administrator account on the Organization, which will use a `service-linked` role (SLR).

<img src=".assets/sharing.png" />

---

### Clean-up

```sh
terraform destroy -auto-approve
```
