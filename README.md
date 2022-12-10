Terraform MongoDB Atlas Cluster
===============================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-mongodbatlas-cluster.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-mongodbatlas-cluster)

A Terraform module for creating a MongoDB cluster in MongoDB Atlas.

The MongoDB cluster requires:
* An existing project within a MongoDB organisation

The MongoDB cluster consists of:
* TODO

Usage
-----

To use the module, include something like the following in your Terraform
configuration:

```hcl-terraform
module "mongodbatlas_cluster" {
  source  = "infrablocks/cluster/mongodbatlas"
  version = "0.1.0"
}
```

As mentioned above, the cluster deploys into an existing project. 
Whilst the project can be created using any mechanism you like, the 
[MongoDB Atlas Project](https://github.com/infrablocks/terraform-mongodbatlas-project)
module will create everything you need. See the 
[docs](https://github.com/infrablocks/terraform-mongodbatlas-project/blob/master/README.md)
for usage instructions.

See the 
[Terraform registry entry](https://registry.terraform.io/modules/infrablocks/cluster/mongodbatlas/latest) 
for more details.

### Inputs

| Name                             | Description                                                                   | Default             | Required                             |
|----------------------------------|-------------------------------------------------------------------------------|:-------------------:|:------------------------------------:|


### Outputs

| Name                                    | Description                                               |
|-----------------------------------------|-----------------------------------------------------------|

### Compatibility

This module is compatible with Terraform versions greater than or equal to 
Terraform 1.0.

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed 
on your development machine:

* Ruby (3.1.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 3.1.1
rbenv rehash
rbenv local 3.1.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

To provision module infrastructure, run tests and then destroy that 
infrastructure, execute:

```bash
./go
```

To provision the module contents:

```bash
./go deployment:root:provision[<seed>]
```

To destroy the module contents:

```bash
./go deployment:root:destroy[<seed>]
```

### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```
ssh-keygen -m PEM -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Generating a self-signed certificate

To generate a self signed certificate:
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

To decrypt the resulting key:

```
openssl rsa -in key.pem -out ssl.key
```

#### Add a git-crypt user

To adding a user to git-crypt using their GPG key: 

```
gpg --import ~/path/xxxx.pub
git-crypt add-gpg-user --trusted GPG-USER-ID

```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at 
https://github.com/infrablocks/terraform-mongodbatlas-cluster. 
This project is intended to be a safe, welcoming space for collaboration, and 
contributors are expected to adhere to the 
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

License
-------

The library is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
