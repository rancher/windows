# Windows Charts

This directory contains Helm charts for developers to deploy common workloads that can assist in debugging issues with Windows clusters.

## Simple Installation

While each chart's `README.md` has instructions for how to deploy the chart using the Helm CLI from a forked copy of this repository, a user or developer of Rancher may find it easier to follow the below steps to add this repository onto your downstream cluster via Apps & Marketplace.

### In Rancher (via Apps & Marketplace)

1. Navigate to `Apps & Marketplace -> Repositories` in your target downstream cluster and create a Repository that points to a `Git repository containing Helm chart or cluster template definitions` where the `Git Repo URL` is `https://github.com/rancher/windows` and the `Git Branch` is `main`
2. Navigate to `Apps & Marketplace -> Charts`; you should see the charts in this repository under the new Repository

### For Developers

Once you follow the above steps, if you change the `Git Repo URL` and `Git Branch` to point to your fork, you can push changes to your fork and click on `Refresh Repository` (note: you may need to do it a couple of times for Rancher to pick up a change you committed) to automatically pick up the new Helm chart from your fork.

This may be a quicker developer workflow to avoid the necessity to run Helm CLI commands locally from a terminal that is pointing to your downstream cluster.
