# Create Namespaces terraform module

Creates the namespace with the provided name in the cluster. The namespace and 
its contents will be destroyed first before creating the new namespace. The pull 
secret will copied and added to the `default` service account. Also, the `ibmcloud-config` and
`ibmcloud-apikey` configmap and secret will be copied from the default namespace into the new 
namespace.
