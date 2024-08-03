# Image Signing from Travis CI - EXAMPLE
![Python](https://img.shields.io/badge/-Python-3776AB?style=flat-square&logo=python&logoColor=white)
![travisci](https://img.shields.io/badge/-TravisCI-4e4847?style=flat-square&logo=travisci&logoColor=e0da53)
![yaml](https://img.shields.io/badge/-YAML-black?style=flat-square&logo=yaml&logoColor=red)
![Linux](https://img.shields.io/badge/-Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![Docker](https://img.shields.io/badge/-Docker-2496ED?style=flat-square&logo=docker&logoColor=white)

## Purpose

The purpose of this example is to demonstrate how to create and sign a Docker image in Travis CI and push it into a container image registry.

In this example, we use a Cloud Object Storage service to store the Garasign client package. The credentials are removed from the client package and stored separately as environment variables in Travis CI.

Here is the example [.travis.yml](/.travis.yml) file that contains the **magic 🪄**.

## Pre-requisites

1. You are registered for a Code Signing Service.
2. You have a GitHub repository, and it is linked to [Travis CI](https://travis-ci.com/).
3. You have a Cloud Object Storage or Artifactory to store the Garasign client package. However, you can store the client package somewhere else as well.

## Preparations

1. Download the [Local signing client](https://www.garasign.com) from the Garasign UI.
   ![GarasignClientDownload.png](/assets/GarasignClientDownload.png)
2. Take the client package that you just downloaded (e.g., `client.tgz`), unzip/untar it.
   1. Copy the content of `credentials.txt` into a secret environment variable (e.g., `GARASIGN_PASSWORD`) in the Travis CI configuration.
   2. Take the binary `.pfx` file (e.g., `client_auth_300_1676290298644.pfx`) and convert it to base64 format to store it as a Travis CI secret (e.g., `GARASIGN_PFX`). Use the command below to create a base64 encoded version of the pfx file:

      ```bash
      base64 -i client_auth_300_1676290298644.pfx -o pfx.txt
      ```

      Copy the content of `pfx.txt` and paste it into the Travis environment variable.

   3. **Remove these two files from the client package!**
   4. Tar and zip the content of the `client.tgz` (without the `credentials.txt` and `*.pfx` files) and store its name in a secret environment variable (e.g., `GARASIGN_CLIENT`).
   5. Upload this new `client.tgz` to a repository like Cloud Object Storage or Artifactory.
3. Store the credentials of the Cloud Object Storage or Artifactory in a Travis environment variable. In this example, we use Cloud Object Storage, so the environment variable is `COS_APIKEY`.
4. Configure your container registry and store the credentials in two environment variables in Travis CI:
   1. Username to `REGISTRY_USER`
   2. Password to `REGISTRY_PASSWORD`
5. These environment variables should exist by now and will be used by Travis CI:
   1. `COS_APIKEY`
   2. `GARASIGN_PASSWORD`
   3. `GARASIGN_PFX`
   4. `GARASIGN_CLIENT`
   5. `REGISTRY_HOST`
   6. `REGISTRY_USER`
   7. `REGISTRY_PASSWORD`
   8. `REGISTRY_NAMESPACE`
   9. `REGISTRY_IMAGE_NAME`
6. When the image signing runs successfully in Travis CI, you should see output similar to the following:

 ```bash
Pushing image docker.io/dotbrains/nodejs-docker-example-nonprod:development-d26c550188e445f522d3157cb8c5b928a70ce8d4
The push refers to repository [docker.io/dotbrains/nodejs-docker-example-nonprod]
development-d26c550188e445f522d3157cb8c5b928a70ce8d4: digest: sha256:e9179947e9d8cacfbed477f6421c4f20680811bc0cece3636cb153a9b62d8d66 size: 3261
uri pkcs11:token=Garantir%20Token;slot-id=1;id=%83%ca%73%6c%dd%41%54%1f%42%33%af%74%f5%a1%a6%53%03%d7%29%72;object=EalCodeSigningcert02262023?module-path=/usr/local/lib/Garantir/GRS/libgrsp11.so
key EalCodeSigningcert02262023
[2023-04-21T14:56:01Z] - INFO | ==== Exporting public key to "/home/travis/build/dotbrains/nodejs-docker-example/EalCodeSigningcert02262023.pem.pub.key"
[2023-04-21T14:56:01Z] - INFO |  - OK
[2023-04-21T14:56:01Z] - INFO | ==== Exporting leaf certificate to "/home/travis/build/dotbrains/nodejs-docker-example/EalCodeSigningcert02262023.pem.cer"
[2023-04-21T14:56:01Z] - INFO |  - OK
[2023-04-21T14:56:01Z] - INFO | ==== Exporting GPG public key to "/home/travis/build/dotbrains/nodejs-docker-example/EalCodeSigningcert02262023.pub.asc"
[2023-04-21T14:56:01Z] - INFO | == Begin GPG output ==
[2023-04-21T14:56:01Z] - INFO | == End GPG output ==
[2023-04-21T14:56:01Z] - INFO |  - OK
[2023-04-21T14:56:01Z] - INFO | ==== Exporting certificate chain to "/home/travis/build/dotbrains/nodejs-docker-example/EalCodeSigningcert02262023.pem.chain"
[2023-04-21T14:56:01Z] - INFO |  - OK
[2023-04-21T14:56:01Z] - INFO | Command execution succeeded
digest docker.io/dotbrains/nodejs-docker-example-nonprod@sha256:e9179947e9d8cacfbed477f6421c4f20680811bc0cece3636cb153a9b62d8d66
Signing image docker.io/dotbrains/nodejs-docker-example-nonprod:development-d26c550188e445f522d3157cb8c5b928a70ce8d4
Pushing signature to: docker.io/dotbrains/nodejs-docker-example-nonprod
Verification for docker.io/dotbrains/nodejs-docker-example-nonprod@sha256:e9179947e9d8cacfbed477f6421c4f20680811bc0cece3636cb153a9b62d8d66 --
The following checks were performed on each of these signatures:

- The cosign claims were validated
- The signatures were verified against the specified public key
[{"critical":{"identity":{"docker-reference":"docker.io/dotbrains/nodejs-docker-example-nonprod"},"image":{"docker-manifest-digest":"sha256:e9179947e9d8cacfbed477f6421c4f20680811bc0cece3636cb153a9b62d8d66"},"type":"cosign container image signature"},"optional":{"Subject":""}}]
Done. Your build exited with 0.
 ```

## Configure Container Registry

A container registry repository is required to push an image into a container registry. The following steps describe how to create a container registry repository across different cloud providers.

1. To create a container registry repository, visit the registry service UI provided by your cloud provider.
2. Navigate to the section where you can manage repositories (often called "Repositories" or "Registries") and click on the `New Repository` button.
3. Add a name for your repository (e.g., _myapp-nonprod_) and configure it for the appropriate environment (e.g., _nonprod_, _prod_).
   1. The name of the repository will be used as the `REGISTRY_IMAGE_NAME` environment variable in Travis CI.
   2. The name of the project or organization (depending on the provider) will be used as the `REGISTRY_NAMESPACE` environment variable.
4. Store the credentials for accessing the repository in Travis CI environment variables:
   1. Username to `REGISTRY_USER`
   2. Password to `REGISTRY_PASSWORD`
   3. Registry Host URL to `REGISTRY_HOST`
   4. Namespace or Project Name to `REGISTRY_NAMESPACE`
   5. Repository Name to `REGISTRY_IMAGE_NAME`

5. Congratulations 🥳, you have created a container registry repository.

You will want to have **two** repositories: one for the _nonprod_ environment and one for the _prod_ environment. The names of the repositories should be the same as the name of the images but suffixed with the environment.

For example:

| Environment | Repository       | Image |
|-------------|------------------|-------|
| nonprod     | myapp-nonprod     | myapp |
| prod        | myapp-prod        | myapp |

Use the above steps to create these two repositories.

To allow Travis CI to push images to both _nonprod_ and _prod_ repositories, we need to create a credential that has _write_ permission to both repositories.

1. To create a credential, visit the registry service UI provided by your cloud provider.
2. Navigate to the `Credentials` section and click on the `New Credential` button.
3. Give the credential a name (e.g., _travis_build_pipelines_).
4. Click on the menu on the right side of the credential and select `Permissions`.
5. Select the repositories that you want to give the credential _write_ access to (e.g., _myapp-nonprod_ and _myapp-prod_).
6. Congratulations 🥳, you now have a universal credential for use in Travis CI.

### Provider-Specific Instructions

#### **AWS Elastic Container Registry (ECR):**
- **Repositories:** Create separate repositories under ECR for `nonprod` and `prod`.
- **Credentials:** Use AWS IAM roles or access keys for `REGISTRY_USER` and `REGISTRY_PASSWORD`.
- **Registry Host:** `REGISTRY_HOST` will be something like `*.dkr.ecr.<region>.amazonaws.com`.

#### **Google Container Registry (GCR) / Artifact Registry:**
- **Repositories:** Create repositories under Google Cloud’s GCR or Artifact Registry.
- **Credentials:** Use service account keys, stored as environment variables in Travis CI.
- **Registry Host:** For GCR, use `gcr.io` or `*.gcr.io`.

#### **Azure Container Registry (ACR):**
- **Repositories:** Create repositories within an Azure Container Registry.
- **Credentials:** Use the admin username and password for the registry, or create a service principal for authentication.
- **Registry Host:** Use your Azure Container Registry’s login server (e.g., `myregistry.azurecr.io`).

#### **Docker Hub:**
- **Repositories:** Create repositories directly in Docker Hub.
- **Credentials:** Use your Docker Hub username and an access token.
- **Registry Host:** Use `docker.io`.

### Final Notes

- Ensure that the credentials stored in Travis CI have the necessary permissions to push images to the repositories.
- The environment variable setup in Travis CI will enable secure and automated deployment of your Docker images.

## Secrets

Create a `.env` file from the [.env.example](/.env.example) file and fill in the values.

```bash
cp .env.example .env
```

## Upload COS File

The [upload_cos_file.py](/scripts/upload_cos_file/upload_cos_file.py) script uploads the `client.tgz` to Cloud Object Storage. This is necessary because the `client.tgz` is too large to be stored in Travis CI environment variables (which have a limit of 4MB), and it is not possible to store it in a file in the repository because it is a secret.

Make sure that the `client.tgz` is in the `scripts/upload_cos_file` folder and is named `modified_client.tgz`. The contents of the `client.tgz` should be the same as described in the [Preparations](#preparations) section. The `credentials.txt` and `*.pfx` files should be removed.

To run the script, you need to install the packages listed in the [requirements.txt](/scripts/upload_cos_file/requirements.txt) file.

```bash
pip3 install -r scripts/upload_cos_file/requirements.txt
```

Then you can run the script:

```bash
python3 scripts/upload_cos_file/upload_cos_file.py
```

## Docker

The Dockerfile performs the tasks laid out in the [.travis.yml](/.travis.yml) file.

Build the image:

```bash
docker compose build
```

Run the image:

```bash
docker compose up
```

## License

[Apache 2.0](LICENSE)
