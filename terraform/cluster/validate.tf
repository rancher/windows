resource "null_resource" "validate_inputs" {
  lifecycle {
    precondition {
      condition     = var.distribution != "rke1" || contains(["flannel"], var.cni)
      error_message = "Only flannel is supported as a CNI provider for RKE2 clusters at this time."
    }

    precondition {
      condition     = var.distribution != "rke2" || contains(["calico"], var.cni)
      error_message = "Only calico is supported as a CNI provider for RKE2 clusters at this time."
    }
  }
}